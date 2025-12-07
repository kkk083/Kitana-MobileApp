-- ============================================================================
-- Script d'initialisation de la base de données pour Kintana Project
-- Base de données: kintana_project_GL
-- Moteur: PostgreSQL
-- ============================================================================

-- Supprimer les tables si elles existent déjà (pour réinitialisation)
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================================================
-- Table: users
-- Description: Stocke les informations des utilisateurs
-- ============================================================================
CREATE TABLE users (
    id_user SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'etudiant',
    date_creation TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances de recherche
CREATE INDEX idx_users_email ON users(email);

-- ============================================================================
-- Table: password_resets
-- Description: Stocke les tokens de réinitialisation de mot de passe
-- ============================================================================
CREATE TABLE password_resets (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users (id_user) ON DELETE CASCADE,
    token VARCHAR(255) UNIQUE NOT NULL,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_used BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index pour améliorer les performances
CREATE INDEX idx_password_resets_token ON password_resets(token);
CREATE INDEX idx_password_resets_user_id ON password_resets(user_id);
CREATE INDEX idx_password_resets_is_used ON password_resets(is_used);
CREATE INDEX idx_password_resets_expires_at ON password_resets(expires_at);

-- ============================================================================
-- Données de test (optionnel - à supprimer en production)
-- ============================================================================
-- Note: Le mot de passe pour tous les utilisateurs de test est "Test1234"
-- Hash bcrypt de "Test1234": $2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyJSo.4B9QQO

-- Utilisateur de test 1
INSERT INTO users (nom, email, password, role)
VALUES (
    'Test User',
    'test@example.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyJSo.4B9QQO',
    'etudiant'
);

-- Utilisateur de test 2
INSERT INTO users (nom, email, password, role)
VALUES (
    'Admin Kintana',
    'admin@kintana.com',
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyJSo.4B9QQO',
    'professeur'
);

-- ============================================================================
-- Vérifications
-- ============================================================================
-- Afficher le nombre d'utilisateurs créés
SELECT COUNT(*) as total_users FROM users;

-- Afficher les utilisateurs
SELECT id_user, nom, email, date_creation
FROM users
ORDER BY id_user;

-- ============================================================================
-- Fin du script d'initialisation
-- ============================================================================
COMMENT ON TABLE users IS 'Table des utilisateurs du système';
COMMENT ON TABLE password_resets IS 'Table des tokens de réinitialisation de mot de passe';

COMMENT ON COLUMN users.id_user IS 'Identifiant unique de l''utilisateur';
COMMENT ON COLUMN users.nom IS 'Nom complet de l''utilisateur';
COMMENT ON COLUMN users.email IS 'Email unique de l''utilisateur';
COMMENT ON COLUMN users.password IS 'Hash bcrypt du mot de passe';
COMMENT ON COLUMN users.date_creation IS 'Date de création du compte';

COMMENT ON COLUMN password_resets.user_id IS 'Référence vers l''utilisateur';
COMMENT ON COLUMN password_resets.token IS 'Token unique de réinitialisation';
COMMENT ON COLUMN password_resets.is_used IS 'Indique si le token a été utilisé';
COMMENT ON COLUMN password_resets.expires_at IS 'Date d''expiration du token';
COMMENT ON COLUMN password_resets.created_at IS 'Date de création du token';

-- Message de confirmation
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '========================================';
    RAISE NOTICE '✓ Base de données initialisée avec succès';
    RAISE NOTICE '========================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Tables créées:';
    RAISE NOTICE '  - users (id_user, nom, email, password, date_creation)';
    RAISE NOTICE '  - password_resets';
    RAISE NOTICE '';
    RAISE NOTICE 'Utilisateurs de test:';
    RAISE NOTICE '  - test@example.com / Test1234';
    RAISE NOTICE '  - admin@kintana.com / Test1234';
    RAISE NOTICE '';
END $$;
