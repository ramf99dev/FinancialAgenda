# Agenda Financiera iOS 📱💼

[![iOS 26+](https://img.shields.io/badge/iOS-26%2B-blue.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg?style=flat-square&logo=swift)](https://swift.org/)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-green.svg?style=flat-square&logo=supabase)](https://supabase.com/)
[![Aesthetic](https://img.shields.io/badge/UI-Liquid%20Glass-purple.svg?style=flat-square)](https://developer.apple.com/design/)

Una agenda financiera nativa premium para iOS diseñada con la estética de **Liquid Glass** de iOS 26+ y arquitectura **MVVM (Model-View-ViewModel)** robusta. Permite a los usuarios gestionar sus finanzas personales, presupuestos y cuentas en tiempo real conectándose de forma segura a una base de datos de Supabase.

---

## 🌟 Características Principales

*   **Diseño Premium Liquid Glass:** Interfaz minimalista, translúcida y animada que aprovecha los efectos visuales modernos nativos de iOS 26+.
*   **Gestión Multimoneda:** Soporte para transacciones en múltiples monedas (USD, VES/Bs.) con conversión dinámica.
*   **Arquitectura de Presupuestos:** Planificación mensual por categorías con alertas de límites de gasto.
*   **Historial Detallado:** Vista unificada de ingresos y gastos con buscador y filtros avanzados por fecha, tipo y categoría.
*   **Seguridad Extrema:** Integración nativa con Supabase y políticas estrictas de seguridad a nivel de fila (Row Level Security - RLS).

---

## 🛠️ Stack Tecnológico

*   **UI Framework:** SwiftUI con soporte nativo para efectos de cristal líquido (Liquid Glass).
*   **Lenguaje:** Swift 6 con concurrencia estructurada avanzada (`async/await`).
*   **Base de Datos y Autenticación:** Supabase Swift SDK (Auth, Database, RLS).
*   **Gestión de Dependencias:** Swift Package Manager (SPM) integrado directamente en el proyecto Xcode.

---

## 🚀 Guía de Instalación y Configuración

Sigue estos pasos para poner en marcha el proyecto localmente:

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/agendafinanciera.git
cd agendafinanciera
```

### 2. Ejecutar el script de inicialización
El script generará tu archivo local `Secrets.swift` a partir de la plantilla y le asignará permisos seguros:
```bash
chmod +x setup.sh
./setup.sh
```

### 3. Configurar tus Secretos
Abre el archivo generado en `Core/Networking/Secrets.swift` e introduce tus credenciales de Supabase:
```swift
public struct Secrets {
    public static let supabaseURL = "https://tu-proyecto.supabase.co"
    public static let supabaseKey = "tu-anon-key-de-supabase"
}
```

### 4. Abrir en Xcode
1. Abre `agendafinanciera.xcodeproj` en **Xcode 26+**.
2. Xcode descargará automáticamente los paquetes de dependencias de Supabase a través de SPM.
3. Elige un simulador de iOS 26+ o tu dispositivo físico y presiona `Cmd + R` para compilar y ejecutar.

---

## 🗄️ Esquema de Base de Datos (Supabase SQL)

Copia y ejecuta este script SQL en el editor de consultas (SQL Editor) de tu dashboard de Supabase para configurar la base de datos necesaria para la aplicación. El script incluye Row Level Security (RLS) para proteger los datos de cada usuario:

```sql
-- ==============================================================================
-- 1. TABLA: CATEGORÍAS (categories)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS categories (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    icon_name TEXT NOT NULL,
    hex_color TEXT NOT NULL
);

-- Habilitar RLS en Categorías
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para Categorías (Usuarios ven las del sistema [user_id IS NULL] y las suyas propias)
CREATE POLICY "Ver categorias públicas y del usuario"
    ON categories FOR SELECT
    USING (user_id IS NULL OR auth.uid() = user_id);

CREATE POLICY "Insertar categorias propias"
    ON categories FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Actualizar categorias propias"
    ON categories FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Eliminar categorias propias"
    ON categories FOR DELETE
    USING (auth.uid() = user_id);

-- Insertar Categorías del Sistema por defecto
INSERT INTO categories (id, name, icon_name, hex_color) VALUES
    ('salary', 'Salario', 'briefcase.fill', '34C759'),
    ('food', 'Alimentos', 'fork.knife', 'FF9500'),
    ('transport', 'Transporte', 'car.fill', '007AFF'),
    ('housing', 'Vivienda', 'house.fill', 'AF52DE'),
    ('entertainment', 'Ocio', 'gamecontroller.fill', 'FF2D55'),
    ('invest', 'Inversiones', 'chart.line.uptrend.xyaxis', '5AC8FA'),
    ('other', 'Otros', 'cube.fill', '8E8E93')
ON CONFLICT (id) DO NOTHING;


-- ==============================================================================
-- 2. TABLA: CUENTAS BANCARIAS (accounts)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS accounts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('checking', 'savings', 'credit', 'cash', 'crypto', 'wallet')),
    balance NUMERIC(12,2) NOT NULL DEFAULT 0,
    account_number TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS en Cuentas
ALTER TABLE accounts ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para Cuentas
CREATE POLICY "Usuarios ven sus propias cuentas"
    ON accounts FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuarios insertan sus propias cuentas"
    ON accounts FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan sus propias cuentas"
    ON accounts FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan sus propias cuentas"
    ON accounts FOR DELETE USING (auth.uid() = user_id);


-- ==============================================================================
-- 3. TABLA: TRANSACCIONES (transactions)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    account_id UUID REFERENCES accounts(id) ON DELETE SET NULL,
    amount NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    type TEXT NOT NULL CHECK (type IN ('income', 'expense')),
    category TEXT NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
    note TEXT,
    date TIMESTAMPTZ DEFAULT now()
);

-- Habilitar RLS en Transacciones
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para Transacciones
CREATE POLICY "Usuarios ven sus propias transacciones"
    ON transactions FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuarios insertan sus propias transacciones"
    ON transactions FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan sus propias transacciones"
    ON transactions FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan sus propias transacciones"
    ON transactions FOR DELETE USING (auth.uid() = user_id);


-- ==============================================================================
-- 4. TABLA: PRESUPUESTOS (budgets)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS budgets (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    category_id TEXT NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    amount NUMERIC(12,2) NOT NULL DEFAULT 0,
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    year INTEGER NOT NULL CHECK (year >= 2020),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, category_id, month, year)
);

-- Habilitar RLS en Presupuestos
ALTER TABLE budgets ENABLE ROW LEVEL SECURITY;

-- Políticas de RLS para Presupuestos
CREATE POLICY "Usuarios ven sus propios presupuestos"
    ON budgets FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Usuarios insertan sus propios presupuestos"
    ON budgets FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan sus propios presupuestos"
    ON budgets FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan sus propios presupuestos"
    ON budgets FOR DELETE USING (auth.uid() = user_id);


-- ==============================================================================
-- 5. TRIGGER AUTOMÁTICO: ACTUALIZACIÓN DE BALANCE DE CUENTAS
-- ==============================================================================
-- Función que actualiza el balance de la cuenta afectada al insertar, actualizar o borrar transacciones
CREATE OR REPLACE FUNCTION fn_update_account_balance()
RETURNS TRIGGER AS $$
BEGIN
    -- Caso 1: Nueva transacción insertada
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.type = 'income') THEN
            UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id;
        ELSIF (NEW.type = 'expense') THEN
            UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id;
        END IF;
    
    -- Caso 2: Transacción eliminada
    ELSIF (TG_OP = 'DELETE') THEN
        IF (OLD.type = 'income') THEN
            UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id;
        ELSIF (OLD.type = 'expense') THEN
            UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id;
        END IF;
        
    -- Caso 3: Transacción actualizada
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Revertir valores antiguos
        IF (OLD.type = 'income') THEN
            UPDATE accounts SET balance = balance - OLD.amount WHERE id = OLD.account_id;
        ELSIF (OLD.type = 'expense') THEN
            UPDATE accounts SET balance = balance + OLD.amount WHERE id = OLD.account_id;
        END IF;
        
        -- Aplicar valores nuevos
        IF (NEW.type = 'income') THEN
            UPDATE accounts SET balance = balance + NEW.amount WHERE id = NEW.account_id;
        ELSIF (NEW.type = 'expense') THEN
            UPDATE accounts SET balance = balance - NEW.amount WHERE id = NEW.account_id;
        END IF;
    END IF;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Crear el Trigger asociado a la tabla transactions
CREATE TRIGGER tr_transactions_balance_sync
AFTER INSERT OR UPDATE OR DELETE ON transactions
FOR EACH ROW EXECUTE FUNCTION fn_update_account_balance();

-- Índices de Rendimiento
CREATE INDEX IF NOT EXISTS idx_accounts_user ON accounts(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_user ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_budgets_user ON budgets(user_id, month, year);
```

---

## 📂 Estructura del Código

El proyecto está estructurado de acuerdo con la Clean Architecture adaptada a MVVM en SwiftUI:

```
├── agendafinanciera/            # Archivo de entrada de la App y vistas raíz
├── Core/                        # Componentes compartidos del sistema
│   ├── Networking/              # Cliente centralizado de Supabase y gestión de secretos
│   ├── Styles/                  # Tokens de diseño, fuentes, colores y layouts de Liquid Glass
│   ├── Utilities/               # Formateadores de monedas, fechas y utilidades de mapeo
│   └── Models/                  # Modelos de dominio mapeados con Supabase (Codables)
├── Modules/                     # Módulos de funcionalidad independientes
│   ├── Auth/                    # Autenticación de usuarios (Registro, Login, Recuperación)
│   ├── Dashboard/               # Vista resumen, saldos, gráficos de gasto e indicadores
│   ├── Transactions/            # Flujo de registro de transacciones con teclado personalizado
│   ├── History/                 # Listado completo de transacciones con búsqueda y filtros
│   └── Profile/                 # Preferencias de usuario, selector de moneda y configuraciones
└── Resources/                   # Recursos del sistema (Assets, plists)
```

---

## 👥 Contribuciones y Buenas Prácticas

Si deseas colaborar con el desarrollo del proyecto, por favor ten en cuenta las siguientes directrices:

*   **Comentarios de Código:** Escribe comentarios profesionales, estructurados y escalables siempre en **español** y sin emojis dentro del código fuente.
*   **Estilo Swift:** Respeta el orden y los modificadores de acceso de Swift (`public`, `internal`, `private`) manteniendo el modelo MVVM limpio (las vistas no deben contener lógica de negocio).
*   **Seguridad:** Nunca hagas commit de archivos de configuración modificados locales que contengan claves privadas. Asegúrate siempre de que `git status` no muestre secretos pendientes de subir.

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para obtener más detalles.
