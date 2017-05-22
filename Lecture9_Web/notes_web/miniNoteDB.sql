-- MySQL dump 10.13  Distrib 5.7.18, for Linux (x86_64)
--
-- Host: localhost    Database: miniNoteDB
-- ------------------------------------------------------
-- Server version	5.7.18-0ubuntu0.17.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `favorites`
--

DROP TABLE IF EXISTS `favorites`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `favorites` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `users` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (8,2,'1,5,3,'),(9,1,'5,2,6,3,'),(10,6,'5,2,3,1,'),(11,3,'5,6,2,'),(12,7,'');
/*!40000 ALTER TABLE `favorites` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `userid` int(11) NOT NULL,
  `title` text,
  `text` text NOT NULL,
  `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `users` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8 COMMENT=' ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes`
--

LOCK TABLES `notes` WRITE;
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
INSERT INTO `notes` VALUES (7,2,'Одиночество','В беспрерывном одиночестве ум становится все острее. Для того, чтобы думать и изобретать не нужна большая лаборатория. Идеи рождаются в условиях отсутствия влияния на разум внешних условий. Секрет изобретательности в одиночестве.\r\nВ одиночестве рождаются идеи.','2017-05-21 00:06:45','ALL,'),(9,1,'Не понятно','Не понятно, как передать, нажав по ссылке,\r\nпараметр','2017-05-22 09:36:32',''),(10,1,'Тесла','Эта заметка должна быть видна только Николе Тесле','2017-05-22 10:46:11','2,'),(12,2,'Проверка доступности','Эта заметка видна Павлу и Тому.','2017-05-21 19:18:56','tomkruzzz,pavelnen,'),(29,2,'Студентам','Не будет большим злом, если студент впадет в заблуждение; если же ошибаются великие умы, мир дорого оплачивает их ошибки.','2017-05-21 00:06:00','ALL,'),(38,5,'','Что я уважаю в людях, так это естественность и подлинность. Мне нравится смотреть в душу. Я стремлюсь быть честным человеком.','2017-05-21 00:10:24','ALL,'),(39,5,'О Чёрной Вдове','Этот персонаж развивался с годами и позволял развиваться мне самой. К тому же это очень загадочная героиня с удивительным прошлым, что давало мне немало возможностей для работы.','2017-05-21 00:10:11','ALL,'),(40,5,'Не жди','Если в твоей жизни затишье и ты не знаешь, что делать, — жди. Но не жди слишком долго, а если ждёшь слишком долго — делай что-нибудь.','2017-05-21 00:09:57','ALL,'),(41,2,'Природа','Общение с природой укрепило моё тело и разум.','2017-05-21 00:05:40','ALL,'),(42,1,'Хокку','Воскресенье.\r\nПоявляются заметки.\r\nХороший сайт.','2017-04-21 10:44:30','ALL,'),(43,1,'CSRF_protection','Сайт должен быть\r\nзащищён от\r\nхакеров','2017-05-22 09:35:44',''),(44,1,'Заметка','Привет, Саня','2017-05-22 10:14:58',''),(45,1,'Длинные слова','«Тетрагидропиранилциклопентилтетрагидропиридопиридиновые»\r\n«Гидразинокарбонилметилбромфенилдигидробенздиазепин»','2017-05-22 11:03:12','6,5,2,');
/*!40000 ALTER TABLE `notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` mediumtext CHARACTER SET utf8 COMMENT 'Имя человека',
  `lastname` mediumtext CHARACTER SET utf8 COMMENT 'Фамилия человека',
  `email` varchar(80) COLLATE utf8_bin DEFAULT NULL,
  `username` varchar(50) COLLATE utf8_bin DEFAULT NULL,
  `password` varchar(80) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Пользователи соцсети';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Павел','Ненашев','nps-11@mail.ru','pavelnen','1234'),(2,'Никола','Тесла','tesla@m.ru','nikolatesla','1234'),(5,'Скарлетт','Йоханссон','bw@m.ru','blackwidow','1234'),(6,'Санек','','sanya@sanyok.s','Саня','1234');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-22 15:45:03
