#! /bin/ksh

. ./settings

if [ -z $REDSHIFT_HOST ]
then
	echo "Value for env variable REDSHIFT_HOST not defined. Please edit the settings file."
	exit -1
fi

if [ -z $REDSHIFT_DB ]
then
	echo "Value for env variable REDSHIFT_DB not defined. Please edit the settings file."
	exit -1
fi

if [ -z $REDSHIFT_UNAME ]
then
	echo "Value for env variable REDSHIFT_UNAME not defined. Please edit the settings file."
	exit -1
fi

if [ -z $REDSHIFT_PORT ]
then
	echo "Value for env variable REDSHIFT_PORT not defined. Please edit the settings file."
	exit -1
fi

psql -c '\timing'  -h $REDSHIFT_HOST -U $REDSHIFT_UNAME -p $REDSHIFT_PORT -d $REDSHIFT_DB -f $1 -W
