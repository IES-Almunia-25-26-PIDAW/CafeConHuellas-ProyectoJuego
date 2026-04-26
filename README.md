# Cafe con Huellas — README

> ⚠️ **Proyecto en desarrollo activo.** Varias de las mecánicas principales están implementadas y son funcionales, pero gran parte de los assets (imágenes, sonidos, sprites) son temporales y serán reemplazados por los definitivos antes de la entrega final. Algunas funcionalidades menores también están aún en construcción.

---

## 📋 1. Requisitos previos

Para ejecutar este proyecto solo necesitas instalar **una única herramienta**: el motor de videojuegos **Godot Engine 4**.

> No hace falta instalar ningún lenguaje de programación, compilador, ni ningún plugin adicional. Godot incluye todo lo necesario.

### Godot Engine 4

| Campo | Valor |
|---|---|
| **Versión requerida** | Godot 4 — `4.6.1` o superior (la web oficial ofrece actualmente `4.6.2`, ambas son compatibles) |
| **Descarga oficial** | https://godotengine.org/download/windows/ |
| **Tipo de descarga** | Versión **estándar** (sin ".NET") |

> 💡 **Nota sobre el plugin `godot-git-plugin`:** El proyecto tiene instalado un plugin para gestionar Git desde dentro del editor de Godot. Es una herramienta de desarrollo interno y **no afecta en absoluto a ejecutar o probar el juego**. No hace falta configurarlo ni activarlo.

#### Cómo descargarlo e instalarlo

1. Ve a https://godotengine.org/download/windows/
2. Descarga la versión **estándar** (sin ".NET"). El archivo tendrá un nombre similar a:
   ```
   Godot_v4.6.x-stable_win64.zip
   ```
3. Extrae el `.zip`. Obtendrás **dos archivos**:
   - `Godot_v4.6.x-stable_win64.exe` ← **este es el que hay que ejecutar**
   - `Godot_v4.6.x-stable_win64_console.exe` ← versión con consola de depuración, no es necesaria
4. **No requiere instalación.** Ejecuta directamente el primero.

> 💡 Godot es una aplicación portable: no se instala en el sistema, no toca el registro de Windows y se puede borrar simplemente eliminando el ejecutable.

---

## 🚀 2. Guía de puesta en marcha

Sigue estos pasos en orden para tener el proyecto funcionando desde cero.

---

### Paso 1 — Descargar el proyecto

Clona el repositorio con Git. Abre una terminal (PowerShell o CMD) y ejecuta:

```bash
git clone https://github.com/IES-Almunia-25-26-PIDAW/CafeConHuellas-ProyectoJuego.git
```

Esto creará una carpeta con todos los archivos del proyecto. Dentro encontrarás, entre otros, el archivo `project.godot` — ese es el archivo que le dice a Godot dónde está el proyecto.

> Si no tienes Git instalado, también puedes descargarlo como `.zip` desde GitHub haciendo clic en `Code → Download ZIP` y extrayendo el contenido.

---

### Paso 2 — Abrir Godot

Ejecuta el archivo `Godot_v4.6.x-stable_win64.exe` que descargaste antes. Se abrirá el **Gestor de Proyectos** de Godot, que es la pantalla desde la que se gestionan todos los proyectos:

```
┌──────────────────────────────────────────────┐
│   GODOT — GESTOR DE PROYECTOS                │
│                                              │
│   [ Nuevo ]  [ Importar ]  [ Escanear ]      │
│                                              │
│   (aquí aparecerán los proyectos recientes)  │
└──────────────────────────────────────────────┘
```

---

### Paso 3 — Importar el proyecto

1. Haz clic en el botón **"Importar"**
2. En la ventana que aparece, haz clic en **"Examinar"**
3. Navega hasta la carpeta que clonaste en el Paso 1
4. Selecciona el archivo **`project.godot`** y haz clic en **"Abrir"**
5. Haz clic en **"Importar y Editar"**

---

### Paso 4 — Esperar la importación inicial

La **primera vez** que abres el proyecto, Godot procesa y optimiza todos los recursos (imágenes, audio, etc.). Verás una barra de progreso en la parte inferior de la pantalla.

**Espera a que desaparezca antes de continuar.** Suele tardar entre 10 y 30 segundos dependiendo del ordenador.

Cuando termine, se abrirá el **editor principal de Godot** con el proyecto listo.

---

### Paso 5 — Verificar los Autoloads *(comprobación opcional pero recomendada)*

El proyecto usa una serie de scripts globales llamados **Autoloads** (singletons) que se cargan automáticamente al iniciar el juego. Para confirmar que están correctamente registrados, ve a:

```
Menú superior → Proyecto → Configuración del Proyecto → pestaña "Autoload" o "Globales"
```

Deberías ver estos entradas en la lista:

| Nombre | Script |
|---|---|
| `DataLoader` | `res://scripts/autoload/data_loader.gd` |
| `GameState` | `res://scripts/autoload/game_state.gd` |
| `GlobalSave` | `res://scripts/autoload/global_save.gd` |
| `SaveManager` | `res://scripts/autoload/save_manager.gd` |
| `SceneManager` | `res://scripts/autoload/scene_manager.gd` |
| `SettingsManager` | `res://scripts/autoload/settings_manager.gd` |
| `MusicManager` | `res://scripts/autoload/music_manager.gd` |
| `TransitionManager` | `res://scenes/system/transition_manager.tscn` |
| `UiSoundManager` | `res://scripts/autoload/ui_sound_manager.gd` |
| `KitchenManager` | `res://scripts/autoload/kitchen_manager.gd` |

Si alguno aparece **marcado en rojo** o directamente no está en la lista, sigue estos pasos para añadirlo manualmente:

1. En la misma ventana de Autoload, haz clic en el icono de carpeta del campo **"Ruta"**
2. Navega hasta el script o escena correspondiente según la tabla de arriba y selecciónalo
3. En el campo **"Nombre"** escribe el nombre exacto que aparece en la tabla (por ejemplo, `SceneManager`)
4. Haz clic en **"Añadir"**
5. Repite el proceso para cada entrada que falte

> ⚠️ Fíjate en que `TransitionManager` apunta a una **escena** `.tscn` en `res://scenes/system/`, no a un script `.gd` como el resto. Si necesitas añadirlo manualmente, navega hasta esa carpeta en vez de `scripts/autoload/`.

---

## 🎮 3. Instrucciones de prueba

### 3.1 — Ejecutar el juego completo

Con el proyecto abierto en el editor:

1. Pulsa **`F5`** en el teclado (o haz clic en el botón **▶** en la esquina superior derecha del editor).
2. Si Godot te pregunta cuál es la escena principal, selecciona o escribe:
   ```
   res://scenes/title_screen.tscn
   ```
   y confirma.
3. Se abrirá una nueva ventana con el juego en marcha, mostrando el **menú principal** con las opciones: *Nuevo Juego, Continuar, Álbum y Salir.*
   
Al pulsar **"Nuevo Juego"** comenzará una secuencia de diálogo de prueba. Verás:
- Un fondo de escena (imagen temporal, no definitiva)
- Un personaje con animaciones básicas
- Texto de diálogo que avanza haciendo clic o pulsando cualquier tecla
- En algunos momentos aparecerán **opciones de elección** — cualquiera es válida para probar

> ⚠️ **Casi todo lo que se ve en esta fase es provisional:** los fondos,
> la música y el contenido de los diálogos son assets de prueba. El aspecto y la historia
> definitivos están en desarrollo.

Durante el juego encontrarás un **botón de pausa** en la esquina superior izquierda de la pantalla. Al hacer clic en él se abrirá el menú de pausa con las siguientes opciones:
- **Opciones** — permite ajustar el volumen de música, voces y sonido por separado
- **Salir al menú** — vuelve a la pantalla de título (pedirá confirmación antes)

> ⚠️ Los botones **Guardar** y **Cargar** aparecen en el menú pero están actualmente desactivados — su lógica está pendiente de conectar a la interfaz.

Para **cerrar el juego** pulsa **`F8`** o cierra directamente la ventana. El editor de Godot seguirá abierto.


---

### 3.2 — Probar la escena de la cocina directamente

La escena de la cocina puede ejecutarse de forma **completamente independiente**, sin necesidad de pasar por el menú principal ni por los diálogos. Es la forma más rápida de probar esa mecánica.

**Ruta de la escena dentro del proyecto:**
```
res://scenes/kitchen/cafe_kitchen_scene.tscn
```

#### Cómo abrirla

En la parte **inferior izquierda** del editor de Godot hay un panel llamado **"Sistema de archivos"** que muestra todos los archivos del proyecto, igual que el Explorador de Windows. Desde ahí:

1. Haz doble clic en la carpeta **`scenes`**
2. Luego entra en la carpeta **`kitchen`**
3. Haz doble clic en el archivo **`cafe_kitchen_scene.tscn`**

La escena se abrirá en el panel central del editor.

> 💡 **Sobre las vistas del editor:** Una vez abierta la escena, en la parte superior central del editor verás varias pestañas:
> - **2D** — muestra la escena visualmente, con todos los nodos colocados en pantalla. Es la vista principal para ver cómo está montada la escena.
> - **Script** — muestra el código GDScript asociado a la escena. Desde aquí puedes leer la lógica sin necesidad de ejecutar nada.
>
> Para ver la escena antes de ejecutarla, asegúrate de estar en la pestaña **2D**.

#### Cómo ejecutarla

Con **`cafe_kitchen_scene.tscn`** abierta y visible en el editor, pulsa:

```
F6
```

> **¿Por qué `F6` y no `F5`?**
> - `F5` siempre lanza el juego desde el principio (la pantalla de título).
> - `F6` lanza únicamente la escena que está abierta en el editor en ese momento, lo que permite probar una parte de forma aislada sin recorrer todo el juego.

#### Qué verás al ejecutarla

Al iniciarse, la escena carga automáticamente una **orden de prueba** con cuatro recetas predefinidas: un cappuccino, un batido de fresa, una tarta de manzana y una galleta de mantequilla. Esta orden está definida directamente en el código de forma temporal para poder probar la mecánica sin depender del flujo completo del juego.

La pantalla muestra la lista de ítems del pedido. Para preparar cada uno, interactúa con los elementos de la escena:

| Elemento | Acción |
|---|---|
| **Cafetera** | Clic → abre un menú de ingredientes para preparar el café |
| **Batidora** | Clic → abre un menú de ingredientes para preparar el batido |
| **Estantería de bollería** | Clic → selecciona la repostería del pedido |
| **Estantería de milkshakes** | Clic → selecciona los batidos especiales |
| **Recetario** | Clic → abre el libro de recetas para ver qué ingredientes lleva cada cosa |

Cuando todos los ítems están completos, el **cartel "Orden lista"** se ilumina y se puede hacer clic en él para finalizar el pedido.

> ⚠️ **Nota:** Los botones de ingredientes son actualmente texto simple. Las ilustraciones definitivas de cada ingrediente están pendientes de integrar.

---

## 📁 Estructura del proyecto *(para referencia)*

```
CafeConHuellas-ProyectoJuego/
│
├── addons/                  # Plugins del editor
│   └── godot-git-plugin/    # Plugin para gestionar Git desde dentro de Godot (no afecta al juego)
│
├── assets/                  # Recursos multimedia (mayormente temporales actualmente)
│   ├── audio/               # Música, voces y efectos de sonido
│   ├── cgs/                 # Imágenes de CG para el álbum
│   ├── images/              # Fondos e imágenes de la UI
│   ├── placeholders/        # Assets temporales de prueba
│   ├── sprites/             # Sprites animados de los personajes
│   └── themes/              # Temas visuales para los menús
│
├── resources/
│   ├── data/                # JSON con datos estáticos del juego
│   │   ├── recipes.json     # Recetas disponibles en la cocina
│   │   ├── ingredients.json # Ingredientes y sus propiedades
│   │   └── characters.json  # Datos de los personajes
│   └── story/               # JSON con los diálogos y la narrativa
│
├── scenes/                  # Escenas del juego (.tscn)
│   ├── title_screen.tscn    # ← Punto de entrada del juego
│   ├── cafe_client_zone.tscn  # Escena de diálogo con cliente
│   ├── client_char.tscn       # Componente visual del personaje cliente
│   ├── dialog_ui.tscn         # Interfaz de usuario del sistema de diálogos
│   ├── player_choice.tscn     # Botón de elección del jugador
│   ├── album/               # Galería de imágenes desbloqueables
│   ├── end_of_day/          # Escenas del final del día
│   ├── kitchen/             # Escenas de la mecánica de cocina
│   ├── menus/               # Menú de pausa y ventanas auxiliares
│   └── system/              # Escenas de sistema (transiciones, etc.)
│
├── scripts/                 # Código en GDScript (.gd)
│   ├── autoload/            # Singletons globales del juego
│   ├── character/           # Gestión de personajes y animaciones
│   ├── kitchen/             # Lógica de la cocina
│   ├── menus/               # Scripts de los menús
│   ├── scenes/              # Scripts de escenas concretas
│   └── ui/                  # Componentes de interfaz de usuario
│
└── project.godot            # Archivo de configuración principal del proyecto
```
