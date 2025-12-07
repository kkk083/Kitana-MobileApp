@echo off
REM Script de démarrage rapide pour Kintana Project
REM Ce script configure et démarre tout automatiquement

echo.
echo ================================================================
echo   DEMARRAGE KINTANA PROJECT - Configuration automatique
echo ================================================================
echo.

REM 1. Vérifier que Python est installé
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERREUR] Python n'est pas installe ou pas dans le PATH
    pause
    exit /b 1
)

echo [1/5] Python detecte
echo.

REM 2. Installer les dépendances Python si nécessaire
echo [2/5] Installation des dependances Python...
pip install -q python-dotenv psycopg2 flask flask-cors pyjwt bcrypt
echo   - Dependances installees
echo.

REM 3. Configurer la base de données
echo [3/5] Configuration de la base de donnees...
echo.
echo IMPORTANT: Entrez le mot de passe PostgreSQL quand demande
echo (Laissez vide si aucun mot de passe)
echo.
python setup_database.py
if %errorlevel% neq 0 (
    echo.
    echo [ERREUR] Echec de la configuration de la base de donnees
    echo Verifiez que PostgreSQL est demarre
    pause
    exit /b 1
)
echo.

REM 4. Démarrer l'API Flask
echo [4/5] Demarrage de l''API Flask...
echo.
start "Kintana API" cmd /k "python app.py"
timeout /t 3 /nobreak >nul
echo   - API demarree sur http://localhost:5000
echo.

REM 5. Informations
echo [5/5] Configuration terminee !
echo.
echo ================================================================
echo   ACCES
echo ================================================================
echo.
echo   API Backend: http://localhost:5000
echo   Health check: http://localhost:5000/health
echo   Documentation: http://localhost:5000
echo.
echo ================================================================
echo   PROCHAINES ETAPES
echo ================================================================
echo.
echo   1. Creez les fichiers Flutter (voir CREER_FICHIERS_FLUTTER.md)
echo   2. Executez: cd view/flutter_application
echo   3. Executez: flutter pub add http shared_preferences
echo   4. Executez: flutter run -d chrome
echo.
echo ================================================================
echo.
echo Appuyez sur une touche pour fermer cette fenetre...
pause >nul
