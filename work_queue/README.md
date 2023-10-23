A folder to store data outside the docker container.
Better to store it in completely different folder outide of repository like: 

    volumes:
      - home/${USER}/mariadb:/var/lib/mysql
      - home/${USER}/scratch:/scratch
      - home/${USER}/storage:/storage
      - home/${USER}/work_queue:/work_queue

But as temporary solution, it can be done here
