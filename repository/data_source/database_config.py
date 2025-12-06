"""
Configuration et connexion à la base de données PostgreSQL
"""
import psycopg2
from psycopg2 import pool
from psycopg2.extras import RealDictCursor
import os
from typing import Optional

class DatabaseConfig:
    """Configuration de la base de données PostgreSQL"""
    
    # Informations de connexion
    DB_HOST = os.getenv('DB_HOST', 'localhost')
    DB_PORT = os.getenv('DB_PORT', '5432')
    DB_NAME = os.getenv('DB_NAME', 'kintana_project_GL')
    DB_USER = os.getenv('DB_USER', 'postgres')
    DB_PASSWORD = os.getenv('DB_PASSWORD', '')
    
    # Pool de connexions
    MIN_CONNECTIONS = 1
    MAX_CONNECTIONS = 10
    
    _connection_pool: Optional[pool.SimpleConnectionPool] = None
    
    @classmethod
    def get_connection_pool(cls):
        """Obtenir ou créer le pool de connexions"""
        if cls._connection_pool is None:
            try:
                cls._connection_pool = psycopg2.pool.SimpleConnectionPool(
                    cls.MIN_CONNECTIONS,
                    cls.MAX_CONNECTIONS,
                    host=cls.DB_HOST,
                    port=cls.DB_PORT,
                    database=cls.DB_NAME,
                    user=cls.DB_USER,
                    password=cls.DB_PASSWORD
                )
                print("✓ Pool de connexions créé avec succès")
            except Exception as e:
                print(f"✗ Erreur lors de la création du pool de connexions: {e}")
                raise
        return cls._connection_pool
    
    @classmethod
    def get_connection(cls):
        """Obtenir une connexion depuis le pool"""
        try:
            pool = cls.get_connection_pool()
            connection = pool.getconn()
            return connection
        except Exception as e:
            print(f"✗ Erreur lors de l'obtention de la connexion: {e}")
            raise
    
    @classmethod
    def release_connection(cls, connection):
        """Libérer une connexion vers le pool"""
        try:
            pool = cls.get_connection_pool()
            pool.putconn(connection)
        except Exception as e:
            print(f"✗ Erreur lors de la libération de la connexion: {e}")
            raise
    
    @classmethod
    def close_all_connections(cls):
        """Fermer toutes les connexions du pool"""
        if cls._connection_pool is not None:
            cls._connection_pool.closeall()
            print("✓ Toutes les connexions ont été fermées")


class DatabaseConnection:
    """Context manager pour gérer les connexions à la base de données"""
    
    def __init__(self, commit: bool = True):
        self.connection = None
        self.cursor = None
        self.commit = commit
    
    def __enter__(self):
        """Obtenir une connexion et créer un curseur"""
        self.connection = DatabaseConfig.get_connection()
        self.cursor = self.connection.cursor(cursor_factory=RealDictCursor)
        return self.cursor
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """Libérer la connexion"""
        if exc_type is not None:
            # En cas d'erreur, rollback
            self.connection.rollback()
        else:
            # En cas de succès, commit si nécessaire
            if self.commit:
                self.connection.commit()
        
        if self.cursor:
            self.cursor.close()
        
        if self.connection:
            DatabaseConfig.release_connection(self.connection)
        
        # Ne pas supprimer l'exception
        return False


def test_connection():
    """Tester la connexion à la base de données"""
    try:
        with DatabaseConnection(commit=False) as cursor:
            cursor.execute("SELECT version();")
            version = cursor.fetchone()
            print(f"✓ Connexion réussie à PostgreSQL")
            print(f"  Version: {version['version']}")
            return True
    except Exception as e:
        print(f"✗ Échec de la connexion: {e}")
        return False


if __name__ == "__main__":
    # Test de la connexion
    test_connection()
    DatabaseConfig.close_all_connections()
