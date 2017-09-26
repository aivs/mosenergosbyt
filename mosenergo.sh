#!/bin/bash

LOGIN="11111-111-11"
PASSWORD="12345678"
METER_LEVEL="51632"

###################### LOGIN ######################
RESPONSE=$(curl -v -c cookie.txt https://lkkbyt.mosenergosbyt.ru/common/login.xhtml)
F_LOGIN=$(echo $RESPONSE | sed -e 's/.*lb_login:f_login:rnd" value="//' -e 's/".*$//')
VIEWSTATE=$(echo $RESPONSE | sed -e 's/.*javax.faces.ViewState" value="//' -e 's/".*$//')

RESPONSE=$(curl -L -v -c cookie.txt -b cookie.txt -X POST \
--data-urlencode "lb_login:f_login:rnd=$F_LOGIN" \
--data-urlencode "lb_login:f_login:t_login=$LOGIN" \
--data-urlencode "lb_login:f_login:t_pwd=$PASSWORD" \
--data-urlencode "lb_login:f_login_SUBMIT=1" \
--data-urlencode "javax.faces.ViewState=$VIEWSTATE" \
--data-urlencode "lb_login:f_login:_idcl=lb_login:f_login:l_submit" \
https://lkkbyt.mosenergosbyt.ru/common/login.xhtml)
VIEWSTATE=$(echo $RESPONSE | sed -e 's/.*javax.faces.ViewState" value="//' -e 's/".*$//')

####################### GET THE COST ######################
echo "Показания для ЛС $LOGIN составляют $METER_LEVEL КВт*Ч."

RESPONSE=$(curl -v -c cookie.txt -b cookie.txt -X POST \
-H "Faces-Request: partial/ajax" \
-H "X-Requested-With: XMLHttpRequest" \
--data-urlencode "javax.faces.partial.ajax=true" \
--data-urlencode "javax.faces.source=f_transfer:cm_transf" \
--data-urlencode "javax.faces.partial.execute=@all" \
--data-urlencode "f_transfer:cm_transf=f_transfer:cm_transf" \
--data-urlencode "f_transfer:vl_t1=$METER_LEVEL" \
--data-urlencode "f_transfer_SUBMIT=1" \
--data-urlencode "javax.faces.ViewState=$VIEWSTATE" \
https://lkkbyt.mosenergosbyt.ru/abonent/index.xhtml)

echo "Сумма начислений по этим показаниям составляет" $(echo $RESPONSE | sed -e 's/.*составляет <b>//' -e 's/<.*$//')

####################### SEND METER LEVEL #######################
VIEWSTATE=$(echo $RESPONSE | sed -e 's/.*javax.faces.ViewState"><!\[CDATA\[//' -e 's/\].*$//')
URL="https://lkkbyt.mosenergosbyt.ru$(echo $RESPONSE | sed -e 's/.*action="//' -e 's/".*$//')"

RESPONSE=$(curl -s -c cookie.txt -b cookie.txt -X POST \
-H "Faces-Request: partial/ajax" \
-H "X-Requested-With: XMLHttpRequest" \
--data-urlencode "javax.faces.partial.ajax=true" \
--data-urlencode "javax.faces.source:f_wiz=w_wiz" \
--data-urlencode "javax.faces.partial.execute=f_wiz:w_wiz" \
--data-urlencode "javax.faces.partial.render=f_wiz:w_wiz" \
--data-urlencode "f_wiz:w_wiz=f_wiz:w_wiz" \
--data-urlencode "f_wiz:w_wiz_wizardRequest=true" \
--data-urlencode "f_wiz:w_wiz_stepToGo=pgFinished" \
--data-urlencode "f_wiz_SUBMIT=1" \
--data-urlencode "javax.faces.ViewState=$VIEWSTATE" \
{$URL})

if [[ $RESPONSE == *"Показания вашего счетчика переданы"* ]]; then
	echo "Показания вашего счетчика переданы успешно."
else
	echo "Показания не переданы."
fi
