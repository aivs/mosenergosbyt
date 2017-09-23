#!/bin/bash

RESPONSE=$(curl -c cookie.txt -b cookie.txt https://lkkbyt.mosenergosbyt.ru/common/login.xhtml)
F_LOGIN=$(echo $RESPONSE | sed -e 's/.*lb_login:f_login:rnd" value="//' -e 's/".*$//')
VIEWSTATE=$(echo $RESPONSE | sed -e 's/.*javax.faces.ViewState" value="//' -e 's/".*$//')

curl -c cookie.txt -b cookie.txt -X POST \
--data-urlencode "lb_login%3Af_login%3Arnd=$F_LOGIN" \
--data-urlencode "lb_login%3Af_login%3At_login=11111-111-11" \
--data-urlencode "lb_login%3Af_login%3At_pwd=12345678" \
--data-urlencode "lb_login%3Af_login_SUBMIT=1" \
--data-urlencode "javax.faces.ViewState=$VIEWSTATE" \
--data-urlencode "lb_login%3Af_login%3A_idcl=lb_login:f_login:l_submit" \
--data-urlencode "javax.faces.source:lb_login:f_login:l_submit" \
https://lkkbyt.mosenergosbyt.ru/common/login.xhtml

curl -c cookie.txt -b cookie.txt https://lkkbyt.mosenergosbyt.ru/abonent/index.xhtml