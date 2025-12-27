// 01-introduction.typ
// Multilingual chapter: All languages in one file

// Import language configuration
#import "../lang.typ": current-lang

#let lang-content = (
  en: [
    = Introduction

    Welcome to the LingoDoc sample project. This document demonstrates how to create multilingual documents using Typst and LingoDoc.

    == Purpose

    This project shows how to:
    - Write multilingual content in a single file
    - Use language switching at compile time
    - Organize chapters and content
  ],

  es: [
    = Introducción

    Bienvenido al proyecto de muestra de LingoDoc. Este documento demuestra cómo crear documentos multilingües usando Typst y LingoDoc.

    == Propósito

    Este proyecto muestra cómo:
    - Escribir contenido multilingüe en un solo archivo
    - Usar cambio de idioma en tiempo de compilación
    - Organizar capítulos y contenido
  ],

  fr: [
    = Introduction

    Bienvenue dans le projet exemple LingoDoc. Ce document démontre comment créer des documents multilingues en utilisant Typst et LingoDoc.

    == Objectif

    Ce projet montre comment:
    - Écrire du contenu multilingue dans un seul fichier
    - Utiliser le changement de langue au moment de la compilation
    - Organiser les chapitres et le contenu
  ]
)

#lang-content.at(current-lang, default: lang-content.en)
