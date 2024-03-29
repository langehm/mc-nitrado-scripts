#!/bin/bash

# Serveradresse, Benutzername und Passwort
source config

# Funktion zum Erstellen einer leeren Datei auf dem Server
upload_file() {
    local filename="$1"
    echo "Uploading file $filename to server..."
    
    # Überprüfen, ob die Datei im lokalen Verzeichnis vorhanden ist
    if [ ! -f "$LOCAL_DIRECTORY/$filename" ]; then
        echo "File $filename not found in $LOCAL_DIRECTORY."
        exit 1
    fi
    
    # Hochladen der Datei auf den Server im Hintergrund
    (
        echo "open $SERVER_ADDRESS"
        echo "user $USERNAME $PASSWORD"
        echo "binary"
        echo "cd $REMOTE_DIRECTORY"
        echo "put $LOCAL_DIRECTORY/$filename"
        echo "quit"
    ) | ftp -n &>/dev/null &
}

# Funktion zum Löschen einer Datei auf dem Server
delete_file() {
    local filename="$1"
    echo "Deleting file $filename from server..."
    
    # Löschen der Datei auf dem Server
    {
        echo "open $SERVER_ADDRESS"
        echo "user $USERNAME $PASSWORD"
        echo "cd $REMOTE_DIRECTORY"
        echo "delete $filename"
        echo "quit"
    } | ftp -n &>/dev/null &
}

# Funktion zum Erzeugen einer Verzögerung von 1 Sekunde
delay() {
    echo "Waiting for 3 seconds..."
    sleep 3
}

# Funktion zum Starten des Servers
start_server() {
    echo "Starting server..."
	delete_file "stop"
	delay
	upload_file "start"
	exit 0
}

# Funktion zum Stoppen des Servers
stop_server() {
    echo "Stopping server..."
	local command="stop"
	delete_file "start"
	delay
	upload_file "$command"
	exit 0
}

# Funktion zum Neustarten des Servers
restart_server() {
    echo "Restarting server..."
	upload_file "restart"
	delay
}

# Funtion zum initieren aller Dateien
init_script() {
	echo "Init Folder and Files"
	mkdir -p $LOCAL_DIRECTORY
	cd $LOCAL_DIRECTORY
	touch start
	touch stop
	touch restart
}

# Hauptprogramm
case "$1" in
	-i|--init)
		init_script
		;;
    -s|--start)
        start_server
        ;;
    -t|--stop)
        stop_server
        ;;
    -r|--restart)
        restart_server
        ;;
    *)
        echo "Available commands:"
		echo "  -i | --init    : Initialize folder and files"
		echo "  --start   : Start the server"
		echo "  --stop    : Stop the server"
		echo "  --restart : Restart the server"
        exit 1
esac

exit 0
