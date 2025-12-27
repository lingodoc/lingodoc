// 02-methodology.typ
// Multilingual chapter: All languages in one file

// Import language configuration
#import "../lang.typ": current-lang

#let lang-content = (
  en: [
    = Methodology

    This chapter describes the methodology used in the project.

    == Approach

    We follow a systematic approach to multilingual document creation:

    + Write all language versions in the same file
    + Use Typst's dictionary and content blocks for organization
    + Select language at compile time
    + Preview any language version instantly

    == Tools

    The following tools are essential:

    1. *Typst compiler* for document generation
    2. *Monaco Editor* for code editing with LSP support
    3. *Tauri* for desktop application framework
    4. *Rust* for high-performance backend

    == Workflow

    The typical workflow is:

    ```
    Edit chapter → Preview (select language) → Compile → PDF output
    ```

    Editing a chapter
  ],

  es: [
    = Metodología

    Este capítulo describe la metodología utilizada en el proyecto.

    == Enfoque

    Seguimos un enfoque sistemático para la creación de documentos multilingües:

    + Escribir todas las versiones de idioma en el mismo archivo
    + Usar diccionarios y bloques de contenido de Typst para organización
    + Seleccionar idioma en tiempo de compilación
    + Previsualizar cualquier versión de idioma instantáneamente

    == Herramientas

    Las siguientes herramientas son esenciales:

    1. *Compilador Typst* para generación de documentos
    2. *Monaco Editor* para edición de código con soporte LSP
    3. *Tauri* para framework de aplicación de escritorio
    4. *Rust* para backend de alto rendimiento
5. hola

    == Flujo de Trabajo

    El flujo de trabajo típico es:

    ```
    Editar capítulo → Previsualizar (seleccionar idioma) → Compilar → Salida PDF
    ```
  ],

  fr: [
    = Méthodologie

    Ce chapitre décrit la méthodologie utilisée dans le projet.

    == Approche

    Nous suivons une approche systématique pour la création de documents multilingues:

    + Écrire toutes les versions linguistiques dans le même fichier
    + Utiliser les dictionnaires et blocs de contenu de Typst pour l'organisation
    + Sélectionner la langue au moment de la compilation
    + Prévisualiser n'importe quelle version linguistique instantanément

    == Outils

    Les outils suivants sont essentiels:

    1. *Compilateur Typst* pour la génération de documents
    2. *Monaco Editor* pour l'édition de code avec support LSP
    3. *Tauri* pour le framework d'application de bureau
    4. *Rust* pour le backend haute performance

    == Flux de Travail

    Le flux de travail typique est:

    ```
    Éditer chapitre → Prévisualiser (sélectionner langue) → Compiler → Sortie PDF
    ```
  ]
)

#lang-content.at(current-lang, default: lang-content.en)
