package com.digitalnoticeboard.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String DEFAULT_URL = "jdbc:oracle:thin:@localhost:1521/FREEPDB1";
    private static final String URL = envOrDefault("DB_URL", DEFAULT_URL);
    private static final String USER = envOrDefault("DB_USER", "system");
    private static final String PASSWORD = envOrDefault("DB_PASSWORD", "");

    static {
        try {
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (ClassNotFoundException exception) {
            throw new RuntimeException("Oracle JDBC Driver not found", exception);
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
