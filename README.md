# Digital Notice Board System

Java web application (Servlet + JSP + HTML/CSS/JS) for admin/student notice management.

## 0) Canonical Project Structure (Use This Only)

```text
.
├─ pom.xml
├─ src/
│  └─ main/
│     ├─ java/com/digitalnoticeboard/
│     │  ├─ config/
│     │  ├─ dao/
│     │  ├─ model/
│     │  └─ servlet/
│     └─ webapp/
│        ├─ index.html
│        ├─ admin/
│        ├─ auth/
│        ├─ student/
│        ├─ css/
│        ├─ js/
│        └─ WEB-INF/web.xml
└─ target/   (generated, ignored in git)
```

Placement rules:

- Put all Java source only in `src/main/java`.
- Put all frontend HTML/CSS/JS only in `src/main/webapp`.
- Do not create duplicate frontend folders at repository root.
- Do not edit or commit anything in `target/`.

## 1) Required Software (Final List)

Install these first:

1. **JDK 21** (LTS)  
	- Required by `pom.xml` compiler settings.
2. **Apache Maven 3.9+**  
	- For dependency resolution, build, and packaging.
3. **Apache Tomcat 9.0+**  
	- Servlet 4.0 runtime (`javax.servlet-api:4.0.1`).
4. **MySQL Server 8.0+**  
	- Backend persistence for users and notices.
5. **Git** (optional but recommended)
	- Version control and reproducible setup.
6. **VS Code** (optional but recommended)
	- Development/editor workflow.

## 2) Java/Maven Dependencies

Defined in `pom.xml`:

- `javax.servlet:javax.servlet-api:4.0.1` (scope `provided`)
- `com.mysql:mysql-connector-j:8.4.0`

## 3) Runtime Requirements

### Environment variables (recommended)

Set these for database connectivity:

- `DB_URL` (example: `jdbc:mysql://localhost:3306/digital_notice_board?useSSL=false&serverTimezone=UTC`)
- `DB_USER` (example: `root`)
- `DB_PASSWORD` (example: your MySQL password)

If not provided, app falls back to:

- URL: `jdbc:mysql://localhost:3306/digital_notice_board?useSSL=false&serverTimezone=UTC`
- User: `root`
- Password: empty string

## 4) Database Setup

Create database and tables:

```sql
CREATE DATABASE IF NOT EXISTS digital_notice_board;
USE digital_notice_board;

CREATE TABLE IF NOT EXISTS users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL,
  email VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS notices (
  notice_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  category VARCHAR(100) NOT NULL,
  priority INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expiry_date DATE NULL,
  created_by INT NOT NULL,
  CONSTRAINT fk_notices_user
	 FOREIGN KEY (created_by) REFERENCES users(user_id)
	 ON DELETE RESTRICT
);
```

Seed example users:

```sql
INSERT INTO users (username, password, role, email)
VALUES
('admin1', 'admin123', 'admin', 'admin1@example.com'),
('student1', 'student123', 'student', 'student1@example.com');
```

## 5) Build and Run

From project root:

```bash
mvn clean package
```

Deploy generated WAR:

- `target/digital-notice-board.war` -> Tomcat `webapps/`

Open in browser:

- `http://localhost:8080/digital-notice-board/`

## 6) Frontend-Backend Integration Status

Current integration points:

- Login form posts to `/login` and redirects by role.
- Admin dashboard (`/admin/admin-dashboard.html`) uses `/api/admin/notices` for create/update/delete/list.
- Student dashboard (`/student/student-dashboard.html`) uses `/api/notices` for notice feed.
- Both dashboards now render **only backend data** (no static placeholder cards/rows).

## 7) Known Security Improvements to Consider Next

The app works end-to-end, but these are recommended for production:

- Store hashed passwords instead of plaintext.
- Move DB secrets to a secrets manager or container/runtime config.
- Add CSRF protection for state-changing endpoints.