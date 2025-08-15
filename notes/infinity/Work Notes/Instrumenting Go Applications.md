## Payment Switch

```bash
curl -X POST -H "Content-Type: application/json" -d '{"requestUUID":"VEBA123456","requestId":"DHS03049241","requestTime":"07:24:23.14","custID":"ZCJ96999","mobileNumber":"5044390555", "remAccNumber": "2147483648", "benAccNumber": "2147483750", "benIfsc": "MINC483750", "amount": 1021, "transferType": "IMPS"}' http://localhost:7777/payswitch/reqcredit
```