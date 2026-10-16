# SideloaderApp

Каркас приложения для переподписи IPA своим сертификатом (.p12 + .mobileprovision).
Собирается на GitHub Actions, Xcode на своём компьютере не нужен.

**Bundle ID:** `com.iosfreedom.swissknife.app.QAP6766QQP`  
(точный существующий App ID из твоего аккаунта — чтобы не тратить новый слот)

## Как получить IPA
1. Создай репозиторий на github.com (public, чтобы Actions были бесплатными).
2. Залей в него все файлы из этой папки (в корне должны лежать `project.yml`, `SideloaderApp/` и `.github/`).
   Скрытая папка `.github` обязательно должна попасть в репозиторий.
3. Открой вкладку **Actions**. Сборка стартует сама после push (или нажми **Run workflow** у "Build IPA").
4. Когда сборка станет зелёной, открой её и скачай артефакт **SideloaderApp-ipa** (внутри `SideloaderApp.ipa`).
5. Поставь IPA на айфон через Sideloadly или AltStore / iloader со своим Apple ID.

## Если сборка упала
Открой упавший шаг в Actions, скопируй последние строки с ошибкой и пришли их.

## Структура
- `project.yml` - описание проекта для XcodeGen (iOS 17+)
- `.github/workflows/build.yml` - сборка неподписанного IPA на macOS-раннере
- `SideloaderApp/` - исходники SwiftUI

## Что дальше по приложению
1. Подпись: подключить zsign (C++) через Objective-C++ мост и вызвать из `Signer.sign`.
2. Установка: локальный HTTPS-сервер + manifest.plist + `itms-services://`.
3. Проверка статуса сертификата через OCSP.
4. Парсинг .mobileprovision (срок действия, Team ID).
