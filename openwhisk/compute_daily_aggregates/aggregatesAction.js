function main(params) {
    const request = require('request');

    // Extract parameters
    const local_url= params.local_url;
    const local_token= params.local_token;
    const local_org= params.local_org;
    const local_bucket= params.local_bucket;
  
    const central_url= params.central_url;
    const central_token= params.central_token;
    const central_org= params.central_org;
    const central_bucket= params.central_bucket;
  
  
    // Compute daily aggregates
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const yesterday = new Date(today);
    const tomorrow= new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);
    tomorrow.setDate(tomorrow.getDate() + 1);
  
  
   try{
    const query = `
    from(bucket: "measure")
    |> range(start: ${today.toISOString()}, stop: ${tomorrow.toISOString()})
    |> filter(fn: (r) => r["_measurement"] == "gas_perc" or r["_measurement"] == "humidity" or r["_measurement"] == "temperature")
    |> filter(fn: (r) => r["_field"] == "value")
    |> group(columns: ["datacenter_id", "_measurement"])
    |> aggregateWindow(every: 1d, fn: mean, createEmpty: false)
    |> yield(name: "mean")
  
    from(bucket: "measure")
    |> range(start: ${today.toISOString()}, stop: ${tomorrow.toISOString()})
    |> filter(fn: (r) => r["_measurement"] == "gas_perc" or r["_measurement"] == "humidity" or r["_measurement"] == "temperature")
    |> filter(fn: (r) => r["_field"] == "value")
    |> group(columns: ["datacenter_id", "_measurement"])
    |> aggregateWindow(every: 1d, fn: max, createEmpty: false)
    |> yield(name: "max")
  
  
    from(bucket: "measure")
    |> range(start: ${today.toISOString()}, stop: ${tomorrow.toISOString()})
    |> filter(fn: (r) => r["_measurement"] == "gas_perc" or r["_measurement"] == "humidity" or r["_measurement"] == "temperature")
    |> filter(fn: (r) => r["_field"] == "value")
    |> group(columns: ["datacenter_id", "_measurement"])
    |> aggregateWindow(every: 1d, fn: min, createEmpty: false)
    |> yield(name: "min")
    `;
  
  // Query InfluxDB instance
  const queryURL = `${local_url}/api/v2/query?org=${local_org}&bucket=${local_bucket}&pretty=true`;
  const requestOptions = {
    url: queryURL,
    method: 'POST',
    headers: {
      'Authorization': `Token ${local_token}`,
      'Content-Type': 'application/csv'
    },
    json: {
      query: query
    }
  };
    request(requestOptions, function (error, response, body) {
      if (!error && response.statusCode == 200) {
  
        const output= body;
        const rows = output.split("\n"); // split the string into an array of rows
        var humidity_avg;
        var humidity_max;
        var humidity_min;
        var temperature_avg;
        var temperature_max;
        var temperature_min;
        var gas_perc_avg;
        var gas_perc_max;
        var gas_perc_min;
        var location;
        var j=0;
  
        rows.forEach(row => {
          const columns = row.split(","); // split the row into an array of columns
          columns.shift();
          if(j==0 && columns[0]=="mean"){
            location=columns[5];
            j++;
          }
          if(columns[0]=='max'){
            if(columns[7]=='gas_perc')
              gas_perc_max= columns[5];
            if(columns[7]=='humidity')
              humidity_max= columns[5];
            if(columns[7]=='temperature')
              temperature_max= columns[5];
          }
          if(columns[0]=='min'){
            if(columns[7]=='gas_perc')
              gas_perc_min= columns[5];
            if(columns[7]=='humidity')
              humidity_min= columns[5];
            if(columns[7]=='temperature')
              temperature_min= columns[5];
          }
          if(columns[0]=='mean'){
            if(columns[4]=='gas_perc')
              gas_perc_avg= columns[6];
            if(columns[4]=='humidity')
              humidity_avg= columns[6];
            if(columns[4]=='temperature')
              temperature_avg= columns[6];
          }
        });
        var tday = today.getTime() * 1000000;
        var year=yesterday.getFullYear();
        var month= yesterday.getMonth()+1;
        var day=yesterday.getDate();
        // Construct the InfluxDB line protocol string
        var influxData = `humidity,datacenter_id=${location},year=${year},month=${month},day=${day} avg=${humidity_avg},max=${humidity_max},min=${humidity_min} ${tday}\n`;
        influxData +=`temperature,datacenter_id=${location},year=${year},month=${month},day=${day} avg=${temperature_avg},max=${temperature_max},min=${temperature_min} ${tday}\n`;
        influxData +=`gas_perc,datacenter_id=${location},year=${year},month=${month},day=${day} avg=${gas_perc_avg},max=${gas_perc_max},min=${gas_perc_min} ${tday}\n`;
  
  
  
        const options = {
          url: central_url+'/api/v2/write?org='+central_org+'&bucket='+central_bucket+'&precision=ns',
          method: 'POST',
          headers: {
            'Authorization': 'Token '+central_token,
            'Content-Type': 'text/plain',
            'Accept': 'application/json'
          },
          body: influxData // Use the constructed InfluxDB line protocol string as the request body
        };
    
        request(options, function(err, res, body) {
          if (err) {
            console.error(`Error sending daily aggregates to remote database: ${err}`);
          } else {
            console.log('Daily aggregates inserted into remote database');
          }
        });
      }else {
        console.error(`Error querying local InfluxDB instance: ${error}`);
      }
    });
  }
  catch(e){
    console.log(e);
  }
}