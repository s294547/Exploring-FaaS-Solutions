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
    const halfHourAgo = new Date(today.getTime() - (30 * 60 * 1000));

  
  
   try{
    const query = `  
    from(bucket: "measure")
    |> range(start: ${halfHourAgo.toISOString()}, stop: ${today.toISOString()})
    |> filter(fn: (r) => r["_measurement"] == "gas_perc" )
    |> filter(fn: (r) => r["_field"] == "value")
    |> group(columns: ["datacenter_id", "_measurement"])
    |> aggregateWindow(every: 1d, fn: max, createEmpty: false)
    |> yield(name: "max")
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
        console.log(body);
        const rows = output.split("\n"); // split the string into an array of rows
        var gas_perc_max;
        var location;
        var j=0;
  
        rows.forEach(row => {
          const columns = row.split(","); // split the row into an array of columns
          columns.shift();
          if(j==0 && columns[0]=="max"){
            location=columns[8];
            j++;
          }
          if(columns[0]=='max'){
            if(columns[7]=='gas_perc')
              gas_perc_max= columns[5];
          }
        });
        var tday = today.getTime() * 1000000;
        var year=today.getFullYear();
        var month= today.getMonth()+1;
        var day=today.getDate();
        // Construct the InfluxDB line protocol string
        var influxData =`gas_perc,datacenter_id=${location},year=${year},month=${month},day=${day} max=${gas_perc_max} ${tday}\n`;
        console.log(influxData);
  
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
          console.log(res.statusCode)
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