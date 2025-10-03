services:
  jenkins:
    image: jenkins/jenkins:lts-jdk11
    container_name: jenkins
    privileged: true
    user: root
    ports:
      - "8080:8080"
      - "50000:50000"
    environment:
      DOCKER_HOST: tcp://dind:2375
    volumes:
      - jenkins_home:/var/jenkins_home
    depends_on:
      - dind

  dind:
    image: docker:24-dind
    container_name: dind
    privileged: true
    ports:
      - "2375:2375"
    environment:
      DOCKER_TLS_CERTDIR: ""

volumes:
  jenkins_home:
