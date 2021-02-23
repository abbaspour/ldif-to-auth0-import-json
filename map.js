// https://www.npmjs.com/package/object-mapper
// https://auth0.com/docs/users/bulk-user-import-database-schema-and-examples

exports.map = {
    "apcustomerid": "user_id.field",
    "sn": "family_name",
    "mail": "email",
    "userpassword": [
        {
            key: "custom_password_hash.hash.value",
            transform: (value) => value.substr(9)
        }
        ,
        {
            key: "custom_password_hash.algorithm",
            transform : () => "sha512"
        }
    ]
};
