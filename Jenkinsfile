/*COPIADO Y ADAPTADO DEL EJEMPLO DE MAVEN SIMPLE*/

pipeline {
    agent {
        label 'debian-worker' 
    }
    
    options {
        timestamps() 
    }
    
    stages {
        stage('Checkout project') {
            steps {
                sh "git config --global http.sslVerify false"
                // CAMBIO: Asegúrate de poner la URL de TU FORK de hello-world-java-war
                git branch: "master", url: "https://github.com/djbubble/hello-world-java-war.git"
            }
        }

        stage('Build & Test') {
            steps {
                sh "mvn clean install"
                junit '**/target/surefire-reports/*.xml'
            }
        }

        stage('Mutation Test') {
            steps {
                sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
        }

        stage('SonarQube analysis') {
            steps {
                withSonarQubeEnv('SonarQube USAL') {
                    // CAMBIO: Añadimos un projectKey único para que aparezca como un proyecto nuevo en Sonar
                    sh "mvn sonar:sonar -Dsonar.sourceEncoding=UTF-8 -Dsonar.projectKey=hello-world-war-real"
                }
            }
        }

        stage("Quality Gate") {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    // CAMBIO: Cambiamos el nombre de la imagen a 'mi-web-final' para distinguirla de la anterior
                    sh "docker build -t mi-web-final:${env.BUILD_ID} ."
                    sh "docker build -t mi-web-final:latest ."
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                configFileProvider([configFile(fileId: 'b3385001-6523-43f3-bc63-8c75e791af1c', variable: 'MAVEN_SETTINGS')]) {
                    sh """
                    mvn deploy:deploy-file -s $MAVEN_SETTINGS \
                    -Dfile=target/hello-world-war.war \
                    -DrepositoryId=mi-repo-binarios \
                    -Durl=http://host.docker.internal:8081/repository/mi-repo-binarios/ \
                    -DgroupId=com.scmgalaxy \
                    -DartifactId=hello-world-war \
                    -Dversion=${env.BUILD_ID} \
                    -Dpackaging=war
                    """
                    // CAMBIOS EN NEXUS:
                    // 1. -Dfile: Ahora apuntamos al .war que genera este proyecto.
                    // 2. -DartifactId: Nombre nuevo para el artefacto en Nexus.
                    // 3. -Dversion: Usamos el ID del build para que cada subida sea distinta.
                    // 4. -Dpackaging: Cambiado de jar a war.
                }
            }
        }
    }
}
