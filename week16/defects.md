# INFOMAN1 Week 16 Defects and Retests

Record actual outcomes; do not mark a retest PASS until it has been executed on the local MySQL instance.

## D16-01 — Application DB password missing from the process environment

- **Symptom:** The Week 15 Spring Boot startup log reported `Access denied ... (using password: NO)` for `capstone_app`.
- **Reproduction:** Start Spring Boot from a PowerShell window where `DB_PASSWORD` has not been set.
- **Root cause:** `application.properties` reads `${DB_PASSWORD:}`; an unset variable resolves to an empty password. The MySQL account can be valid while the application process still sends no password.
- **Fix:** Set `DB_URL`, `DB_USERNAME`, and `DB_PASSWORD` in the same PowerShell process that launches Maven. Read the password with `Read-Host -AsSecureString`; never put it in source or Git.
- **Retest:** The later user log changed to `using password: YES`, confirming that the process sent a password; the final successful application connection still needs to be recorded after verifying that the value matches the MySQL account. **Status: retest pending.**

## D16-02 — AccessDeniedHandler attached to the wrong Spring Security configurer

- **Symptom:** Maven compilation reported that `accessDeniedHandler(AccessDeniedHandler)` could not be found on `CsrfConfigurer`.
- **Root cause:** The handler was chained inside `.csrf(...)`, but this API is configured under `.exceptionHandling(...)` for the installed Spring Security version.
- **Fix in Week 16 source:** Keep the CSRF token repository and request handler inside `.csrf(...)`; register both `authenticationEntryPoint` and `accessDeniedHandler` in `.exceptionHandling(...)`.
- **Retest:** Run `mvnw.cmd test`; attach the actual compilation/test summary. **Status: pending local retest.**

## D16-03 — Reader logout matched the Manager-only POST rule (code-review defect)

- **Symptom/risk:** The general `POST /api/**` rule required MANAGER and therefore also covered `POST /api/auth/logout`; a READER could authenticate but could not use the normal logout endpoint.
- **Root cause:** Authorization matchers are evaluated in declaration order; the endpoint-specific logout rule was missing.
- **Fix in Week 16 source:** Add `.requestMatchers(HttpMethod.POST, "/api/auth/logout").authenticated()` before the broad Manager-only POST rule. CSRF remains enabled.
- **Retest:** `SecurityApiTest.readerCanLogoutAndSessionIsInvalidated` supplies a valid session and CSRF token, expects logout 200, then expects protected GET 401. **Status: pending local retest.**
