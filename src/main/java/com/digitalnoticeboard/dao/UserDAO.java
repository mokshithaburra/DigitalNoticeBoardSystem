package com.digitalnoticeboard.dao;

import com.digitalnoticeboard.config.DBConnection;
import com.digitalnoticeboard.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDAO {

    public User authenticateUser(String username, String password, String role) {
        String tableName = resolveUsersTableName();

        String sql = "SELECT user_id, username, password, role, email FROM " + tableName +
            " WHERE LOWER(TRIM(username)) = LOWER(TRIM(?)) AND LOWER(TRIM(role)) = LOWER(TRIM(?))";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, username);
            preparedStatement.setString(2, role);

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    String storedPassword = resultSet.getString("password");
                    if (!isPasswordValid(password, storedPassword)) {
                        return null;
                    }

                    // Backward compatibility: upgrade legacy plaintext password to BCrypt hash on successful login.
                    if (!isBcryptHash(storedPassword)) {
                        String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
                        updatePasswordHash(connection, tableName, resultSet.getInt("user_id"), hashedPassword);
                    }

                    User user = new User();
                    user.setUserId(resultSet.getInt("user_id"));
                    user.setUsername(resultSet.getString("username"));
                    user.setPassword(storedPassword);
                    user.setRole(resultSet.getString("role"));
                    user.setEmail(resultSet.getString("email"));
                    return user;
                }
            }
        } catch (SQLException exception) {
            throw new RuntimeException("Authentication query failed. Check DB_URL/DB_USER/DB_SCHEMA and users table access.", exception);
        }

        return null;
    }

    private String resolveUsersTableName() {
        String schema = System.getenv("DB_SCHEMA");
        if (schema == null || schema.trim().isEmpty()) {
            schema = System.getProperty("DB_SCHEMA");
        }

        if (schema == null || schema.trim().isEmpty()) {
            return "users";
        }

        return schema.trim() + ".users";
    }

    private boolean isPasswordValid(String inputPassword, String storedPassword) {
        if (storedPassword == null) {
            return false;
        }

        if (isBcryptHash(storedPassword)) {
            try {
                return BCrypt.checkpw(inputPassword, storedPassword);
            } catch (IllegalArgumentException exception) {
                return false;
            }
        }

        return storedPassword.equals(inputPassword);
    }

    private boolean isBcryptHash(String value) {
        if (value == null) {
            return false;
        }

        return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
    }

    private void updatePasswordHash(Connection connection, String tableName, int userId, String hashedPassword) {
        String updateSql = "UPDATE " + tableName + " SET password = ? WHERE user_id = ?";
        try (PreparedStatement updateStatement = connection.prepareStatement(updateSql)) {
            updateStatement.setString(1, hashedPassword);
            updateStatement.setInt(2, userId);
            updateStatement.executeUpdate();
        } catch (SQLException ignored) {
            // Login is already validated; ignore hash upgrade failure to preserve existing flow.
        }
    }
}
