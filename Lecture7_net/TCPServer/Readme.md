Необходимо написать прокси-сервер с использованием AnyEvent или Coro
------------------------------
-Реализовать TCP-сервер с текстовым протоколом
-Поддержать команды URL, HEAD, GET, FIN
-Протокол на вход сессионный. URL ассоциируется с соединением.
-Команда HEAD делает HEAD запрос на запомненый URL и возвращает заголовки
-Команда GET делает GET запрос на запомненый URL и возвращает тело
-На команду FIN нужно закрыть соединение и прекратить любую работу
