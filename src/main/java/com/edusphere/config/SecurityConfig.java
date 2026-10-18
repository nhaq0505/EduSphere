package com.edusphere.config;

import com.edusphere.security.AccountStateFilter;
import com.edusphere.security.CustomUserDetailsService;
import com.edusphere.security.RoleAwareAuthenticationSuccessHandler;
import com.edusphere.security.oauth2.CustomOAuth2UserService;

import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.security.web.context.SecurityContextHolderFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final CustomUserDetailsService userDetailsService;
    private final CustomOAuth2UserService oAuth2UserService;
    private final RoleAwareAuthenticationSuccessHandler authenticationSuccessHandler;
    private final AccountStateFilter accountStateFilter;

    public SecurityConfig(CustomUserDetailsService userDetailsService,
                          CustomOAuth2UserService oAuth2UserService,
                          RoleAwareAuthenticationSuccessHandler authenticationSuccessHandler,
                          AccountStateFilter accountStateFilter) {
        this.userDetailsService = userDetailsService;
        this.oAuth2UserService = oAuth2UserService;
        this.authenticationSuccessHandler = authenticationSuccessHandler;
        this.accountStateFilter = accountStateFilter;
    }

    @Bean
    public FilterRegistrationBean<AccountStateFilter> accountStateFilterRegistration(AccountStateFilter filter) {
        FilterRegistrationBean<AccountStateFilter> registration = new FilterRegistrationBean<>(filter);
        registration.setEnabled(false);
        return registration;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public DaoAuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        provider.setHideUserNotFoundExceptions(false);
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config)
            throws Exception {
        return config.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .authorizeHttpRequests(auth -> auth
                .requestMatchers(
                    "/", "/login", "/register",
                    "/verify-otp", "/resend-otp",
                    "/verify-email",
                    "/forgot-password", "/forgot-password/verify-otp", "/forgot-password/resend-otp",
                    "/reset-password",
                    "/assets/**", "/favicon.ico", "/error",
                    "/WEB-INF/**"
                ).permitAll()
                .requestMatchers(HttpMethod.GET, "/courses", "/courses/{courseId}").permitAll()
                .requestMatchers(HttpMethod.POST, "/payments/payos/webhook").permitAll()
                .requestMatchers(HttpMethod.POST, "/courses/{courseId}/checkout").hasRole("STUDENT")
                .requestMatchers(HttpMethod.GET, "/payments/result").hasRole("STUDENT")
                .requestMatchers(HttpMethod.POST, "/courses/{courseId}/enroll").hasRole("STUDENT")
                .requestMatchers("/courses/{courseId}/learn", "/courses/{courseId}/lessons/**").hasRole("STUDENT")
                .requestMatchers("/my-courses").hasRole("STUDENT")
                .requestMatchers("/admin/**").hasRole("ADMINISTRATOR")
                .requestMatchers("/instructor/**").hasRole("INSTRUCTOR")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .successHandler(authenticationSuccessHandler)
                .failureHandler(customAuthenticationFailureHandler())
                .permitAll()
            )
            .logout(logout -> logout
                .logoutRequestMatcher(new AntPathRequestMatcher("/logout", "POST"))
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .clearAuthentication(true)
                .deleteCookies("JSESSIONID")
                .permitAll()
            )
            // Google OAuth2 / OIDC Login
            .oauth2Login(oauth2 -> oauth2
                .loginPage("/login")
                .userInfoEndpoint(userInfo -> userInfo
                    .oidcUserService(oAuth2UserService)  // OIDC cho Google
                )
                .successHandler(authenticationSuccessHandler)
                .failureUrl("/login?oauth2Error=true")
            )
            .authenticationProvider(authenticationProvider())
            .csrf(csrf -> csrf.ignoringRequestMatchers("/payments/payos/webhook"))
            .addFilterAfter(accountStateFilter, SecurityContextHolderFilter.class);

        return http.build();
    }

    @Bean
    public AuthenticationFailureHandler customAuthenticationFailureHandler() {
        return (request, response, exception) -> {
            String errorParam = switch (exception.getClass().getSimpleName()) {
                case "DisabledException"       -> "notVerified";
                case "LockedException"         -> "locked";
                case "BadCredentialsException" -> "badCredentials";
                default                        -> "error";
            };
            response.sendRedirect(request.getContextPath() + "/login?error=" + errorParam);
        };
    }
}
