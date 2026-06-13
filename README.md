# Cafe con Huellas — README

---

## 📋 1. Requisitos previos

Para ejecutar este proyecto solo necesitas instalar **una única herramienta**: el motor de videojuegos **Godot Engine 4**.

> No hace falta instalar ningún lenguaje de programación, compilador, ni ningún plugin adicional. Godot incluye todo lo necesario.

### Godot Engine 4

| Campo | Valor |
|---|---|
| **Versión requerida** | Godot 4 — `4.6.1` o superior (la web oficial ofrece actualmente `4.6.3`, ambas son compatibles) |
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
│   GODOT ENGINE — ADMINISTRADOR DE PROYECTOS  │
│                                              │
│   [ Crear ]  [ Importar ]  [ Escanear ]      │
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
3. Se abrirá una nueva ventana con el juego en marcha, mostrando el **menú principal** con las opciones: *Nuevo Juego, Continuar, Opciones, Álbum y Salir.*

Al pulsar **"Nuevo Juego"** comenzará la configuración inicial del jugador (nombre, pronombres y nombre de la cafetería), seguida de la secuencia de inicio de día y la historia.

Al pulsar **"Continuar"** se mostrará el selector de partidas guardadas (3 slots), donde podrás elegir cualquier slot con datos guardados para reanudar la partida exactamente donde se dejó, incluyendo la escena, el capítulo y la línea de diálogo correspondientes.

Durante el juego encontrarás un **botón de pausa** en la esquina superior izquierda de la pantalla. Al hacer clic en él se abrirá el menú de pausa con las siguientes opciones:

- **Guardar** — abre el selector de slots para guardar la partida actual
- **Cargar** — abre el selector de slots para cargar una partida guardada
- **Opciones** — permite ajustar el volumen de música, voces y efectos de sonido por separado
- **Salir al menú** — vuelve a la pantalla de título (pedirá confirmación antes, ya que se perderá el progreso no guardado)

> 💡 Si guardas la partida dentro de la cocina o del ordenador, al cargar volverás a esa misma escena. El pedido de la cocina y las necesidades de las mascotas en el ordenador se generan de nuevo desde cero al cargar, por diseño.

Para **cerrar el juego** pulsa **`F8`** o cierra directamente la ventana. El editor de Godot seguirá abierto.

---

### 3.2 — Probar la escena de la cocina o el ordenador directamente

Tanto la escena de la cocina como la del ordenador forman parte del flujo normal del juego y se acceden de forma natural a través de la historia (comandos `start_order` y `video_day_end` del guión, respectivamente). No están pensadas para lanzarse de forma aislada con `F6`. Esto sería solo para un escenario de pruebas aisladas, donde se debería preparar un método para cargar datos de prueba y hacer que estas escenas tengan una funcionalidad mínima.

Para llegar a ellas, simplemente avanza la historia desde **"Nuevo Juego"** o **"Continuar"** hasta el punto en el que el guión las indique.

---

## 📜 4. Sistema de guión (comandos JSON)

La narrativa del juego se define en archivos JSON dentro de `res://resources/story/`. Cada archivo es un array de "líneas", donde cada línea es un objeto con uno o varios comandos. El script `cafe_client_scene.gd` procesa estas líneas una a una mediante `process_current_line()`.

A continuación, la lista completa de comandos disponibles:

| Comando | Descripción | Ejemplo |
|---|---|---|
| `location` | Cambia el fondo de la escena | `{"location": "cafeteria"}` |
| `music` | Reproduce una pista musical (independiente del fondo) | `{"music": "little_cafe"}` |
| `sound` | Reproduce un efecto de sonido puntual sin cortar la música | `{"sound": "click_menu"}` |
| `counter` | Muestra u oculta el mostrador delante del personaje | `{"counter": "yes"}` / `{"counter": "no"}` |
| `speaker` + `text` | Línea de diálogo con personaje | `{"speaker": "Jasmine", "text": "Hola!", "expression": "happy"}` |
| `speaker` + `pronouns` | Texto que cambia según los pronombres del jugador | `{"speaker": "Hunter", "pronouns": {"male": "Él sonrió.", "female": "Ella sonrió.", "nonbinary": "Elle sonrió."}}` |
| Variables en texto | Sustituye `{player_name}` o `{cafe_name}` en el texto | `{"speaker": "Jasmine", "text": "Me encanta el café de {cafe_name}, {player_name}!"}` |
| `speaker: narrator` | Texto sin nombre ni cuadro de personaje visible | `{"speaker": "narrator", "text": "El sol se asomaba por la ventana."}` |
| `show_character` | Cambia el sprite/expresión del personaje sin que hable | `{"show_character": "Jasmine", "expression": "sad"}` |
| `hide_character` | Oculta al personaje de la escena con un fade | `{"hide_character": true}` |
| `choices` | Muestra opciones al jugador | `{"choices": [{"text": "Sí", "goto": "anchor_si"}, {"text": "No", "goto": "anchor_no"}]}` |
| `anchor` | Marca un punto del guión al que se puede saltar | `{"anchor": "anchor_si"}` |
| `goto` | Salta incondicionalmente a un anchor | `{"goto": "fin"}` |
| `if_route` | Salta a un anchor solo si el jugador está en esa ruta de personaje | `{"if_route": "jasmine", "goto": "dialogo_jasmine"}` |
| `choose_route` | Abre la pantalla de selección de ruta de personaje | `{"choose_route": true}` |
| `meet_character` | Añade un personaje a los conocidos del jugador | `{"meet_character": "jasmine"}` |
| `add_relationship` | Añade puntos de amistad con un personaje | `{"add_relationship": {"character": "jasmine", "amount": 2}}` |
| `add_clue` | Añade una pista al inventario del jugador | `{"add_clue": "clue_01"}` |
| `add_pet` | Añade una mascota si hay espacio (máx. 6) | `{"add_pet": "rex"}` |
| `unlock_cg` | Desbloquea una ilustración (CG) en el álbum global | `{"unlock_cg": "cg_jasmine_01"}` |
| `change_day` | Cambia el número del día actual | `{"change_day": 2}` |
| `set_var` | Guarda una variable temporal (por ejemplo, una elección) | `{"set_var": {"key": "last_choice", "value": "opcion_a"}}` |
| `if_var` | Salta a un anchor si una variable temporal tiene cierto valor | `{"if_var": {"key": "last_choice", "value": "opcion_a"}, "goto": "anchor_a"}` |
| `start_order` | Envía al jugador a la cocina con un pedido | `{"start_order": ["cappuccino", "cake_apple"], "next_scene_after_order": "chapter_2"}` |
| `next_chapter` | Cambia el capítulo activo sin cambiar de escena ni JSON inmediatamente | `{"next_chapter": "day2a_intro"}` |
| `next_scene` | Cambia al siguiente JSON de historia | `{"next_scene": "story_scene2", "transition": "slide"}` |
| `video_day_start` | Reproduce la animación de inicio de día (con "DÍA X") y cambia de capítulo | `{"video_day_start": "chapter_2", "day": 2}` |
| `video_day_end` | Reproduce la animación de fin de día. Por defecto va al ordenador, pero puede indicarse otra escena | `{"video_day_end": true}` / `{"video_day_end": true, "next_scene": "res://scenes/cafe_client_zone.tscn"}` |
| `end_game` | Termina la partida y vuelve a la pantalla de título | `{"end_game": true, "transition": "fade"}` |

> 💡 **Orden de evaluación:** los comandos sin `text` ni `choices` (como `location`, `music`, `goto`, `add_clue`, etc.) avanzan automáticamente a la siguiente línea sin esperar input del jugador. Solo las líneas con `text` o `choices` detienen el avance hasta que el jugador interactúe.

---

## 📁 Estructura del proyecto *(para referencia)*

```
CafeConHuellas-ProyectoJuego/
│
├── addons/                  # Plugins del editor
│   └── godot-git-plugin/    # Plugin para gestionar Git desde dentro de Godot (no afecta al juego)
│
├── assets/                  # Recursos multimedia
│   ├── audio/
│   │   ├── music/           # Pistas musicales
│   │   ├── sfx/             # Efectos de sonido puntuales
│   │   └── voices/          # Voces de los personajes
│   ├── cgs/                 # Ilustraciones (CGs) para el álbum
│   │   └── thumbs/          # Thumbnails de los CGs o ilustraciones para mostrarlas en el álbum
│   ├── fonts/               # Fuentes de letra usados para el juego
│   ├── images/              # Fondos e imágenes del juego
│   │   ├── backgrounds/     # Fondos de pantalla que se ven en la UI o historia
│   │   ├── computer_items/  # Iconos que se usan en la escena del ordenador
│   │   ├── icons/           # Iconos de los personajes y pistas
│   │   ├── ingredients/     # Iconos de ingredientes de cocina
│   │   ├── kitchen_items/   # Items de la cocina: la cafetera, la batidora, tartas, etc.
│   │   ├── recipes/         # Imágenes de las recetas que aparecen en el popup y libro de recetas
│   │   └── ui/              # Imágenes que se usan en la UI, como el botón del menú o el cursor
│   ├── sprites/             # Sprites animados de mascotas y personajes, cada uno con su carpeta y estructura con diferentes frames
│   ├── themes/              # Temas visuales para los menús y el vídeo de inicio/fin del día
│   └── video_transitions/   # Sprites de los vídeos de inicio y fin del día
│
├── resources/
│   ├── data/                # JSON con datos estáticos del juego
│   │   ├── animals.json       # Datos de las mascotas adoptables
│   │   ├── cgs.json           # Ilustraciones del álbum
│   │   ├── characters.json    # Datos de los personajes
│   │   ├── clues.json         # Pistas de la trama
│   │   ├── emails.json        # Correos de adopción del ordenador
│   │   ├── ingredients.json   # Ingredientes y sus propiedades
│   │   └── recipes.json       # Recetas disponibles en la cocina
│   └── story/               # JSONs con los diálogos y la narrativa, por capítulos
│
├── scenes/                       # Escenas del juego (.tscn)
│   ├── album/                     # Galería de imágenes desbloqueables
│   │   ├── album_card.tscn
│   │   ├── album_screen.tscn      # Escena principal del álbum
│   │   └── cg_viewer.tscn
│   ├── computer/                  # Ordenador: mascotas, correo y pistas
│   │   ├── action_popup.tscn
│   │   ├── character_detail.tscn
│   │   ├── character_icon.tscn
│   │   ├── clues_tab.tscn
│   │   ├── clue_card.tscn
│   │   ├── computer_scene.tscn    # Escena principal del ordenador
│   │   ├── mail_row.tscn
│   │   ├── mail_tab.tscn
│   │   ├── mail_viewer.tscn
│   │   ├── pets_tab.tscn
│   │   ├── pet_card.tscn
│   │   └── result_popup.tscn
│   ├── kitchen/                   # Escenas de la mecánica de cocina
│   │   ├── cafe_kitchen_scene.tscn  # Escena principal de la cocina
│   │   ├── ingredient_popup.tscn
│   │   ├── kitchen_item_button.tscn
│   │   ├── recipe_book.tscn
│   │   └── recipe_completed_popup.tscn
│   ├── menus/                     # Menú de pausa y ventanas auxiliares
│   │   ├── confirm_window.tscn
│   │   ├── options_window.tscn
│   │   ├── pause_button.tscn
│   │   ├── pause_menu.tscn           # Escena principal del menú de pausa
│   │   ├── save_success_window.tscn
│   │   ├── slot_picker_window.tscn
│   │   └── slot_row.tscn
│   ├── system/                    # Escenas de sistema (transiciones, etc.)
│   │   └── transition_manager.tscn
│   ├── cafe_client_zone.tscn      # Escena de diálogo con cliente (escena principal donde ocurre toda la VN)
│   ├── client_char.tscn           # Componente visual del personaje cliente
│   ├── dialog_ui.tscn             # Interfaz de usuario del sistema de diálogos
│   ├── player_choice.tscn         # Botón de elección del jugador
│   ├── player_setup.tscn          # Configuración inicial (nombre, pronombres, cafetería)
│   ├── route_selection.gd         # Selección de ruta de personaje
│   ├── title_screen.tscn          # Escena del título: Punto de entrada del juego
│   └── video_transition.tscn      # Transición animada de inicio/fin de día
│
├── scripts/                      # Código en GDScript (.gd)
│   ├── autoload/                  # Singletons globales del juego
│   │   ├── data_loader.gd
│   │   ├── game_state.gd
│   │   ├── global_save.gd
│   │   ├── kitchen_manager.gd
│   │   ├── music_manager.gd
│   │   ├── save_manager.gd
│   │   ├── scene_manager.gd
│   │   ├── settings_manager.gd
│   │   ├── transition_manager.gd
│   │   └── ui_sound_manager.gd
│   ├── character/                 # Gestión de personajes y animaciones
│   │   ├── character.gd
│   │   └── client_char_sprite.gd
│   ├── computer/                  # Lógica del ordenador (mascotas, correo, pistas)
│   │   ├── action_popup.gd
│   │   ├── character_detail.gd
│   │   ├── character_icon.gd
│   │   ├── clues_tab.gd
│   │   ├── clue_card.gd
│   │   ├── computer_scene.gd
│   │   ├── mail_row.gd
│   │   ├── mail_tab.gd
│   │   ├── mail_viewer.gd
│   │   ├── pets_tab.gd
│   │   ├── pet_card.gd
│   │   └── result_popup.gd
│   ├── kitchen/                   # Lógica de la cocina
│   │   ├── cafe_kitchen_scene.gd
│   │   ├── ingredient_popup.gd
│   │   ├── kitchen_item_button.gd
│   │   ├── recipe_book.gd
│   │   └── recipe_completed_popup.gd
│   ├── menus/                     # Scripts de los menús
│   │   ├── confirm_window.gd
│   │   ├── options_window.gd
│   │   ├── pause_button.gd
│   │   ├── pause_menu.gd
│   │   ├── save_success_window.gd
│   │   ├── slot_picker_window.gd
│   │   └── slot_row.gd
│   ├── scenes/                    # Scripts de escenas concretas
│   │   ├── cafe_client_scene.gd
│   │   ├── player_setup.gd
│   │   └── title_screen.gd
│   └── ui/                        # Componentes de interfaz de usuario
│       ├── album_card.gd
│       ├── album_screen.gd
│       ├── cg_viewer.gd
│       ├── dialog_ui.gd
│       ├── sticker_manager.gd
│       └── video_transition.gd
│
├── default_bus_layout.tres       # Configuración de los buses de audio (Music, Voices, SFX)
├── icon.svg                       # Icono del proyecto
├── icon_pawcafe.png                # Icono del juego
└── project.godot                  # Archivo de configuración principal del proyecto
```
