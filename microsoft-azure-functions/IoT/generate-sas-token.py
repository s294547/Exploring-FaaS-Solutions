import hmac
import hashlib
import base64
import time

conn_str = "HostName=iot-hub-tesi-bianchi.azure-devices.net;SharedAccessKeyName=iothubowner;SharedAccessKey=SVZM2jwm4hjlYmeLORcNb8HK1MUa46HEfoJ/WFHy4Ps="

device_id = "device-trial"
expiry = int(time.time() + 3600)  # Set the expiry time to one hour from now

resource_uri = f"{conn_str.split(';')[0]}/devices/{device_id}"
sas = f"{resource_uri}\n{expiry}"
key = base64.b64decode(conn_str.split('SharedAccessKey=')[1])
signature = hmac.digest(key, msg=sas.encode('utf-8'), digest=hashlib.sha256)
signature = base64.b64encode(signature).decode('utf-8')
sas_token = f"SharedAccessSignature sr={resource_uri}&sig={signature}&se={expiry}"

print(sas_token)