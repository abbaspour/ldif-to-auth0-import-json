# ldif-to-auth0-import-json
Convert LDIF export from various LDAP servers to [Auth0 compatible bulk user import JSON file](https://auth0.com/docs/users/bulk-user-import-database-schema-and-examples#user-json-schema).

## Mapping

Mapping in `map.js` file is from `ldap field` -> `json field`. Here is an example:

```json
{
    "useraccountid": "user_id",
    "sn": "family_name",
    "givenname": "given_name",
    "mail": "email",
    "customerid": "app_metadata.customerid"
}
```

### Sample Mapper for Popular LDAP Hashing Algorithms

| Algorithm | Description | Sample Input | Hash Value | Salt Value |  Salt Position | Encoding |
| ---- | ---- | ---- | ---- | ---- | ---- | ---- |
| SHA | `base64(sha1(pass))` | {SHA}xxxx | `Buffer.from(password.substr(5), 'base64').toString('hex', 0, 20)` | NA | - | hex |
| SSHA | `base64(sha1(pass + salt))` | {SSHA}xxxx== | `Buffer.from(userpassword.substr(6), 'base64').toString('hex', 0, 20)` | `Buffer.from(userpassword.substr(6), 'base64').toString('hex', 20)` | suffix | hex |
| SHA512 | `base64(sha512(pass))` | {SHA512}xxxx | `Buffer.from(userpassword.substr(8), 'base64').toString('hex', 0, 64)` | NA | - | hex |
| SSHA512 | `base64(sha512(pass + salt))` | {SSHA512}xxxx== | `Buffer.from(userpassword.substr(9), 'base64').toString('hex', 0, 64)` | `Buffer.from(userpassword.substr(9), 'base64').toString('hex', 64)` | suffix | hex |

### Example
How to map OpenLDAP SSHA password to Auth0? Here is the map config:

```javascript
{   
    "userpassword": [
        {
            key: "custom_password_hash.algorithm",
            transform: () => "sha1"
        },
        // hash
        {
            key: "custom_password_hash.hash.value",
            transform: (value) => Buffer.from(value.substr(6), 'base64').toString('hex', 0, 20)
        },
        {
            key: "custom_password_hash.hash.encoding",
            transform: (value) => 'hex'
        },
        // salt
        {
            key: "custom_password_hash.salt.value",
            transform: (value) => Buffer.from(value.substr(6), 'base64').toString('hex', 20)
        },
        {
            key: "custom_password_hash.salt.encoding",
            transform: () => 'hex'
        },
        {
            key: "custom_password_hash.salt.position",
            transform: () => 'suffix'
        }
    ]
}
```

## Steps
1. Export users from LDAP server to `myexport.ldif`

2. Copy `map.js` and build your own
```bash
cp map.js my-map.js
vim map.js
```

3. Run Convert 
```bash
./convert.sh -i myexport.ldif -m my-map.js -o users -s 2048
```

4. Import 
```bash
./import.sh -c connection_id -f users.json
```

5. Get import status
```bash
./job-status.sh -i job_id
```

## Benchmark

Benchmarks are with Node.js v14.16.0 on 2.6Ghz 6-core i7 SSD  

> Note: Current version only supports LDIF files up to 2G


| LDIF size (MB) | Output chunk size (MB) | Number of files | Time |
|------ | --- | --- | --- |
| 29m | ~1M | 20 | 6.537s |
| 281m | ~1M | 193 | 4m38.000s |
