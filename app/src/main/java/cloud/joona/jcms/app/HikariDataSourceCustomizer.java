package cloud.joona.jcms.app;

import com.zaxxer.hikari.HikariDataSource;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.context.annotation.Configuration;

import java.sql.DriverManager;
import java.sql.SQLException;

@Configuration
public class HikariDataSourceCustomizer implements BeanPostProcessor {

    private static final Logger log = LogManager.getLogger(HikariDataSourceCustomizer.class);

    @Value("${spring.datasource.url}")
    private String datasourceUrl;

    @Value("${spring.datasource.password}")
    private String datasourcePassword;

    @Value("${spring.datasource.username}")
    private String datasourceUsername;

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) {
        if (bean instanceof HikariDataSource dataSource) {

            // Make sure Oracle DB is queryable.

            try {
                Thread.sleep(2000);
            } catch (InterruptedException e) {
                throw new RuntimeException(e);
            }

            var attempt = 1;
            while (true) {
                try (var connection = DriverManager.getConnection(datasourceUrl, datasourceUsername, datasourcePassword);
                     var statement = connection.createStatement()) {
                    try (var resultSet = statement.executeQuery("SELECT USERNAME FROM ALL_USERS FETCH FIRST 1 ROWS ONLY")) {
                        while (resultSet.next()) {
                            log.info("Fetched username {}.", resultSet.getString("USERNAME"));
                        }
                    }
                } catch (SQLException e) {
                    if (attempt >= 20) {
                        throw new RuntimeException();
                    }

                    log.info("Retrying. Attempt {}.", ++attempt);
                    continue;
                }
                break;
            }

            // After making sure Oracle DB is queryable, set data source values.

            dataSource.setJdbcUrl(datasourceUrl);
            dataSource.setUsername(datasourceUsername);
            dataSource.setPassword(datasourcePassword);
            dataSource.setInitializationFailTimeout(60);
        }

        return bean;
    }
}