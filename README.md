# spark_data_platform_101
One node spark cluster in a docker container.



Docker build command:

```commandline
docker build -t sdp_101 .

```

Docker run command:

```commandline
hostfolder="$(pwd)"
dockerfolder="/home/sparkuser/app"
docker run --rm -it --name sdp-contanier -p 4040:4040 -p 4041:4041 -p 18080:18080 -p 8888:8888 -v ${hostfolder}/app:${dockerfolder} --user $(id -u):$(id -g) sdp_101:latest

```


docker run --rm -d --name spark-container -p 8888:8888 -p 4041:4041 -p4040:4040 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} -v ${hostfolder}/logs:/home/spark/logs -v ${hostfolder}/event_logs:/home/spark/event_logs sdp_101:latest jupyter

docker run --rm -it --name spark-container -p 8888:8888 -p 4041:4041 -p4040:4040 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} sdp_101:latest spark-shell

docker run --rm -it --name spark-container -p 8888:8888 -p 4041:4041 -p4040:4040 -p 18080:18080 -v ${hostfolder}/app:${dockerfolder} sdp_101:latest pyspark


### Pyspark
>>> df = sc.parallelize([[1,2,3], [2,3,4]]).toDF()
>>> df.show()



### Scala: a random dataframe with 4 columns
val df = Seq(("a", "b", "c", "d")).toDF("A", "B", "C", "D")
df.show


docker-compose up jupyter

