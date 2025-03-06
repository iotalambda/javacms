package cloud.joona.jcms.app;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

@Configuration
public class SecurityConfig {

    @Autowired
    private Environment env;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity httpSecurity) throws Exception {
//        httpSecurity
//                .authorizeHttpRequests(auth -> auth
//                        .requestMatchers("/api/**").authenticated().anyRequest().permitAll())
//                .formLogin(AbstractHttpConfigurer::disable);
//        if (List.of(env.getActiveProfiles()).contains("dev")) {
//            httpSecurity
//                    .cors(c -> c.configurationSource(devCorsConfigurationSource()));
//        }

        httpSecurity
                .cors(c -> c.configurationSource(tempInsecureCorsConfigurationSource()));

        return httpSecurity.build();
    }

    private CorsConfigurationSource devCorsConfigurationSource() {
        var corsConfig = new CorsConfiguration();
        corsConfig.setAllowCredentials(true);
        corsConfig.addAllowedMethod("*");
        corsConfig.addAllowedHeader("*");
        corsConfig.addAllowedOrigin("http://localhost:3000");
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);
        return source;
    }

    private CorsConfigurationSource tempInsecureCorsConfigurationSource() {
        var corsConfig = new CorsConfiguration();
        corsConfig.setAllowCredentials(true);
        corsConfig.addAllowedMethod("*");
        corsConfig.addAllowedHeader("*");
        corsConfig.addAllowedOrigin("*");
        var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);
        return source;
    }
}
