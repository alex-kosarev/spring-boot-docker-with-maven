# При помощи ключевого слова FROM необходимо указать исходный образ,
# который мы будем использовать для создания своего.
# Для данного примера выбран образ на основе Debian с установленным
# Liberica OpenJDK 17 версии, поскольку нам он нужен для запуска приложения.
FROM bellsoft/liberica-openjdk-debian:17

# Желательно запускать приложения не от имени суперпользователя, который
# используется по умолчанию, поэтому нужно создать пользователя и группу
# для запуска приложения.
RUN addgroup spring-boot-group && adduser --ingroup spring-boot-group spring-boot
USER spring-boot:spring-boot-group

# Иногда требуется получить доступ к файлам, генерирующимся в процессе выполнения,
# для этого зарегистрируем том /tmp
VOLUME /tmp

# Со временем у проекта будет изменяться версия, и чтобы не изменять всякий раз
# этот Dockerfile имя jar-файла вынесем в аргумент. Альтернативно можно указать
# постоянное имя jar-файла в Maven при помощи finalName.
ARG JAR_FILE=sandbox-greetings-maven-23.1.1-SNAPSHOT.jar


# Создадим рабочую директорию проекта
WORKDIR /application

# Скопируем в рабочую директорию проекта JAR-файл проекта и его зависимости
COPY target/${JAR_FILE} application.jar
COPY target/dependency lib

# В конце укажем точку входа. Выбран вариант с использованием sh -c для того, чтобы
# можно было передать в строку запуска дополнительные параметры запуска - JAVA_OPTS, а так же
# ${0} и ${@} для передачи аргументов запуска.
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -cp lib/*:application.jar pro.akosarev.sandbox.GreetingsMavenApplication ${0} ${@}"]
