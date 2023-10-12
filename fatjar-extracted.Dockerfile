# Нам требуется образ, содержащий maven, при помощи
# ключевого слова as мы указываем псевдоним для контейнера сборки,
# чтобы при его помощи в дальнейшем обращаться к контейнеру
FROM maven:3.9.4-eclipse-temurin-17 as build

# Собирать проект будем в /build
WORKDIR /build

# Теперь необходимо скопировать необходимые для сборки проекта файлы в конейнер
COPY src src
COPY pom.xml pom.xml

# И запустить сборку проекта. Загружаемые библиотеки желательно кэшировать между
# сборками,для этого нужно добавить --mount=type=cache,target=/root/.m2 к RUN
RUN --mount=type=cache,target=/root/.m2 \
    mvn clean package && \
    java -Djarmode=layertools \
    -jar target/sandbox-greetings-maven-23.1.1-SNAPSHOT.jar \
    extract --destination target/extracted

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

# Создадим рабочую директорию проекта
WORKDIR /application

# Скопируем файлы проекта, необходимые для запуска
COPY --from=build /build/target/extracted/application .
COPY --from=build /build/target/extracted/dependencies .
COPY --from=build /build/target/extracted/snapshot-dependencies .
COPY --from=build /build/target/extracted/spring-boot-loader .

# В конце укажем точку входа. Выбран вариант с использованием exec для того, чтобы
# можно было передать в строку запуска дополнительные параметры запуска - JAVA_OPTS, а так же
# ${0} и ${@} для передачи аргументов запуска.
ENTRYPOINT exec java ${JAVA_OPTS} org.springframework.boot.loader.JarLauncher ${0} ${@}
