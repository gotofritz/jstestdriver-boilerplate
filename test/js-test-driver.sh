#!/bin/bash
# js-test-driver.sh

ROOTDIR="$( cd "$( dirname "$0")" && pwd )"
BINDIR=${ROOTDIR}/bin
JSTD_VERSION=1.3.5
JSTDBIN=${BINDIR}/JsTestDriver-$JSTD_VERSION.jar
COVERAGEBIN=${BINDIR}/coverage-$JSTD_VERSION.jar
TEMPDIR=${ROOTDIR}/tmp
MEMORY="-Xms256m -Xmx768m"
PORT_LOCAL="4224"
PORT_HEADLESS="9876"
CONFIG="jstd.conf"
TESTOUTPUT="${TEMPDIR}/coverage"

[ -d TEMPDIR ] && mkdir TEMPDIR;
[ -d TESTOUTPUT ] && mkdir TESTOUTPUT;

function usage {
  echo "Usage: $0 MODE COMMAND

  MODE    local|headless
            local
                you are manually running your own server and capturing browser(s)
            headless
                you are using phantomjs to start a server, run tests on a headless browser, and stop the server

  COMMAND start|run|stop
          for local MODE only
            start
              starts a server you can use to capture browsers
            run
              runs tests
            stop
              stops the server
"
  exit 1
}

MODE=$1
COMMAND=$2
TESTS=$3

if [ $# -lt 1 ]; then
    usage
fi
if [ $# -lt 3 ]; then
    TESTS="all"
fi



if [ ! -f "$JSTDBIN" ]; then
    echo "Downloading JsTestDriver jar ..."
    curl http://js-test-driver.googlecode.com/files/JsTestDriver-$JSTD_VERSION.jar > $JSTDBIN
fi


if [ ! -f "$COVERAGEBIN" ]; then
    echo "Downloading coverage jar ..."
    curl http://js-test-driver.googlecode.com/files/coverage-$JSTD_VERSION.jar > $COVERAGEBIN
fi



if [[ $MODE == "local" ]]; then

  if [ $# -lt 2 ]; then
      usage
  fi


  if [[ $COMMAND == "start" ]]; then

    if [[ -f ${TEMPDIR}/jstd.local.pid ]]; then
      PID=`cat ${TEMPDIR}/jstd.local.pid`
      if [[ -f ${TEMPDIR}/jstd.local.pid ]] && [[ "" != $PID ]]; then
        echo "Server is already running"
        exit 3;
      fi
    fi

    echo "Starting JSTD Server - point your browser to http://localhost:$PORT_LOCAL"
    nohup java -jar $MEMORY $JSTDBIN --port $PORT_LOCAL --config $CONFIG --testOutput $TESTOUTPUT > ${TEMPDIR}/jstd.local.out 2> ${TEMPDIR}/jstd.local.err < /dev/null &
    # echo "java -jar $MEMORY $JSTDBIN --port $PORT_LOCAL --config $CONFIG --testOutput $TESTOUTPUT "
    echo $! > ${TEMPDIR}/jstd.local.pid


  elif [[ $COMMAND == "run" ]]; then

    if [[ -f ${TEMPDIR}/jstd.local.pid ]]; then
      echo "running tests"
      java $MEMORY -jar $JSTDBIN --tests $TESTS --config $CONFIG --reset --captureConsole --server http://localhost:$PORT_LOCAL
    #   echo "java $MEMORY -jar $JSTDBIN --tests $TESTS --config $CONFIG --reset --captureConsole --server http://localhost:$PORT_LOCAL"
    else
      echo "No server running"
    fi



  elif [[ $COMMAND == "stop" ]]; then

    echo "Killing JSTD Server"
    PID=`cat ${TEMPDIR}/jstd.local.pid`
    kill $PID
    rm -f ${TEMPDIR}/jstd.local.out ${TEMPDIR}/jstd.local.err ${TEMPDIR}/jstd.local.pid

  else
    usage

  fi


elif [[ $MODE == "headless" ]]; then

    command -v phantomjs >/dev/null 2>&1 || { echo "Can't find phantomjs, please make sure it's on your PATH." >&2; exit 2; }

    echo "Starting JSTD Server"
    nohup java -jar $MEMORY $JSTDBIN --port $PORT_HEADLESS --config $CONFIG > ${TEMPDIR}/jstd.headless.out 2> ${TEMPDIR}/jstd.headless.err < /dev/null &

    echo $! > ${TEMPDIR}/jstd.headless.pid

    sleep 1;

    echo "Starting PhantomJS"
    nohup phantomjs lib/phantomjs-jstd.js > ${TEMPDIR}/phantomjs.out 2> ${TEMPDIR}/phantomjs.err < /dev/null &
    echo $! > ${TEMPDIR}/phantomjs.pid

    sleep 4;

    echo "Running tests"
    java -jar $MEMORY $JSTDBIN --server http://localhost:$PORT_HEADLESS  --config $CONFIG --testOutput $TESTOUTPUT --tests all

    echo "Killing JSTD Server"

    PID=`cat ${TEMPDIR}/jstd.headless.pid`
    kill $PID

    rm -f ${TEMPDIR}/jstd.headless.out ${TEMPDIR}/jstd.headless.err ${TEMPDIR}/jstd.headless.pid

    echo "Killing PhantomJS"

    PID=`cat ${TEMPDIR}/phantomjs.pid`
    kill $PID

    rm -f ${TEMPDIR}/phantomjs.out ${TEMPDIR}/phantomjs.err ${TEMPDIR}/phantomjs.pid

else

  usage

fi

exit 0
