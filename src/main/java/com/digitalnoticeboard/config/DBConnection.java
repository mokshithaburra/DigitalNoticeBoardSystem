package com.digitalnoticeboard.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/digital_notice_board?useSSL=false&serverTimezone=UTC";
    private static final String URL = envOrDefault("DB_URL", DEFAULT_URL);
    private static final String USER = envOrDefault("DB_USER", "root");
    private static final String PASSWORD = envOrDefault("DB_PASSWORD", "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException exception) {
            throw new RuntimeException("MySQL JDBC Driver not found", exception);
        }
    }

    private DBConnection() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private static String envOrDefault(String key, String fallback) {
        String value = System.getenv(key);
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
