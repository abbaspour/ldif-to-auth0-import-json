// https://www.npmjs.com/package/object-mapper
// https://auth0.com/docs/users/bulk-user-import-database-schema-and-examples

exports.map = {
    "useraccountid": "user_id",
    "sn": "family_name",
    "givenname": "given_name",
    "mail": "email",
    "customerid": "app_metadata.customerid",
    "userpassword": [
        {
            key: "custom_password_hash.hash.value",
            transform: (value) => value.substr(46)
        },
        {
            key: "custom_password_hash.hash.encoding",
            transform: (value) => 'base64'
        },
        {
            key: "custom_password_hash.salt.value",
            transform: (value) => value.substr(9, 36)
        },
        {
            key: "custom_password_hash.salt.position",
            transform: () => 'prefix'
        },
        {
            key: "custom_password_hash.salt.encoding",
            transform: () => 'utf8'
        },
        {
            key: "custom_password_hash.algorithm",
            transform: () => "sha512"
        }
    ]
};
