using Newtonsoft.Json;

namespace Company.Function;

internal class Post
{
    [JsonProperty(PropertyName = "id")]
    public string id { get; set; } 

    [JsonProperty(PropertyName = "device_id")]
    public double device_id { get; set; }

    [JsonProperty(PropertyName = "humidity")]
    public double humidity { get; set; }

    [JsonProperty(PropertyName = "temperature")]
    public double temperature { get; set; }

    [JsonProperty(PropertyName = "gas_perc")]
    public double gas_perc { get; set; }

    /*[JsonProperty(PropertyName = "timestamp")]
    public string timestamp { get; set; }*/
}