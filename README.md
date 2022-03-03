# User module

This module is reponsible for providing a simple blog platform for Feather CMS.



```script
# login 
curl \
-X POST \
-H 'Content-Type: application/json' \
-d '{"email": "root@feathercms.com", "password": "ChangeMe1"}' \
"http://localhost:8080/api/login/" | jq


# get account details (profile only)
curl \
-X GET \
-H 'Authorization: Bearer lS4g3TR0rtfyKZu2pvqFkAfXJ2MPy0puOEAVv5zvxg8NUQB4S0RU0Og6LcG3ekCp' \
-H 'Content-Type: application/json' \
"http://localhost:8080/api/profile/" | jq


# send reset password email
echo '{
    "email": "root@feathercms.com",
}'| curl -X POST "http://localhost:8080/api/reset-password/" \
-H 'Content-Type: application/json' \
-d @- | jq


# set new password using token
echo '{
    "token": "u1Vb4Uq7ZNaIMVaY8f8WaESsHEzCuldygrheMb0R1CSK1xfYWtDmSnvm88a5LR3O",
    "password": "ChangeMe1"
}'| curl -X POST "http://localhost:8080/api/new-password/" \
-H 'Content-Type: application/json' \
-d @- | jq

    


curl \
    -X POST "http://localhost:8080/api/admin/system/variables/" \
    -H 'Authorization: Bearer 6pH99KwlBbxwFwEB4F3oJPTHzGWsTgfNvPkanbF3hHPTv7tjQLQinRU3uJQesODg' \
    -H 'Content-Type: application/json' \
    -d ' \
    {\
        "name": "486B0B47-9785-43C9-B52C-AABC5D77718D"
    }' | jq
```
