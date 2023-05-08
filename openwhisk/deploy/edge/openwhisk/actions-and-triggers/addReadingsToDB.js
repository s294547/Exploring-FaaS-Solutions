function main(args) {
  var request = require('request');
  console.log("body: ");
  console.log(typeof args.body);
  const url= args.influx_url;
  const token= args.influx_token;
  const org= args.influx_org;
  const bucket= args.influx_bucket;

  try{

    const data = JSON.parse(args.body); // Parse the string into a JSON object
    const currentTime = Date.now() * 1000000;

    const keys = Object.keys(data);
// Construct the InfluxDB line protocol string

    let influxData = '';
    for (let i = 0; i < keys.length; i++) {
      if(keys[i]!="device_fingerprint" && keys[i]!="datacenter_id")
        influxData += `${keys[i]},datacenter_id=${data["datacenter_id"]},device_fingerprint=${data["device_fingerprint"]} value=${data[keys[i]]} ${currentTime}\n`;
    }

const options = {
  url: url+'/api/v2/write?org='+org+'&bucket='+bucket+'&precision=ns',
  method: 'POST',
  headers: {
    'Authorization': 'Token '+token,
    'Content-Type': 'text/plain',
    'Accept': 'application/json'
  },
  body: influxData // Use the constructed InfluxDB line protocol string as the request body
};
  
  request(options, function(err, res, body) {
    console.log(err);
  });
  }
  catch(e){
    console.log(e);
  }
}
