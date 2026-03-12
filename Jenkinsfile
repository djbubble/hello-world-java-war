/*COPIADO Y ADAPTADO DEL EJEMPLO DE MAVEN SIMPLE*/

pipeline {
    agent {
        label 'debian-worker' 
    }

    // Definir la herramienta que configuré en "Global Tool Configuration" para que en lugar de usar el Maven con propia instalación, use el local del Debian.
    tools {
        maven 'MAVEN_LOCAL'            // Extraido del snippet -> tool name: 'MAVEN_LOCAL', type: 'maven'
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
                // Comentamos esto porque no hay tests en este repo
                // junit '**/target/surefire-reports/*.xml'
            }
        }

        // Saltamos Mutation Test por ahora ya que no hay tests que mutar
        /* stage('Mutation Test') { ... } 
        */

        stage('SonarQube analysis') {
            steps {
                // Usamos el credentialsId que me dio el Snippet
                withSonarQubeEnv(credentialsId: 'sonar-token-id') {            
                    sh """
                    mvn sonar:sonar \
                    -Dsonar.projectKey=hello-world-war-real \
                    -Dsonar.projectName='Aplicacion Web USAL - Desarrollo' \
                    -Dsonar.projectVersion=${env.BUILD_ID} \
                    -Dsonar.language=java \
                    -Dsonar.sourceEncoding=UTF-8
                    """
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
                    // Usamos el nombre real generado por Maven
                    sh "docker build -t mi-web-final:latest ."
                }
            }
        }

        stage('Deploy to Nexus') {
            steps {
                configFileProvider([configFile(fileId: 'b3385001-6523-43f3-bc63-8c75e791af1c', variable: 'MAVEN_SETTINGS')]) {
                    sh """
                    mvn deploy:deploy-file -s $MAVEN_SETTINGS \
                    -Dfile=target/hello-1.0.war \
                    -DrepositoryId=mi-repo-binarios \
                    -Durl=http://host.docker.internal:8081/repository/mi-repo-binarios/ \
                    -DgroupId=com.boxfuse.samples \
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
