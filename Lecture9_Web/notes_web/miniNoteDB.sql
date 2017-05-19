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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `favorites`
--

LOCK TABLES `favorites` WRITE;
/*!40000 ALTER TABLE `favorites` DISABLE KEYS */;
INSERT INTO `favorites` VALUES (1,1,'nikolatesla,tomkruzzz,'),(2,2,'pavelnen,tomkruzzz,');
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
) ENGINE=InnoDB AUTO_INCREMENT=30 DEFAULT CHARSET=utf8 COMMENT=' ';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes`
--

LOCK TABLES `notes` WRITE;
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
INSERT INTO `notes` VALUES (1,1,'First','Привет, Мир!','2017-04-18 21:59:28',''),(2,1,'','Без заголовка заметка','2017-04-18 21:59:58',''),(3,1,'Только заголовок','','2017-04-18 22:01:18',''),(4,1,'Simple','','2017-04-18 22:02:58',''),(5,1,'etgsr','','2017-04-18 22:06:00',''),(6,1,'','asdff','2017-04-18 22:06:26',''),(7,2,'Секрет изобретательности','В беспрерывном одиночестве ум становится все острее. Для того, чтобы думать и изобретать не нужна большая лаборатория. Идеи рождаются в условиях отсутствия влияния на разум внешних условий. Секрет изобретательности в одиночестве.\r\nВ одиночестве рождаются идеи.','2017-04-19 00:10:53',''),(8,3,'Я','Я верю в жизнь. Я знаю, что вся жизнь идет из твоего сердца. И будь ты хоть актером, режиссером, или просто человеком с улицы – все в твоем сердце. Вот, что дает мне Саентология – умение жить и ценить мою жизнь.','2017-04-19 02:02:04',''),(9,1,'День №20','Не понятно, как передать, нажав по ссылке, параметр','2017-04-19 10:00:21',''),(10,1,'Доступность','Эта заметка должна быть видна Николе Тесле','2017-04-19 11:57:25','nikolatesla,'),(11,2,'Дступность №2','Эта заметка видна Павлу и Тому.','2017-04-19 11:58:20',','),(12,2,'Дступность №2.1','Эта заметка видна Павлу и Тому.','2017-04-19 11:59:20','tomkruzzz,'),(13,1,'Shared','Проверка','2017-04-19 12:01:56','tomkruzzz,'),(14,1,'Проверка доступности','Раз два три','2017-04-19 12:03:49','tomkruzzz,,'),(15,1,'Again','qwerty','2017-04-19 12:05:05',','),(16,1,'Again2','qwer','2017-04-19 12:05:17','tomkruzzz,'),(17,1,'123','123','2017-04-19 12:12:49','tomkruzzz,'),(18,1,'124','124','2017-04-19 12:22:49','Notes::Controller::Notes=HASH(0x55c6582f9130),'),(19,1,'234','23','2017-04-19 12:26:32',',,'),(20,1,'345','35','2017-04-19 12:27:14','Mojo::Transaction::HTTP=HASH(0x55c656ae8010),,Notes=HASH(0x55c657bedaf8),,HASH(0x55c65823e5c0),,Mojolicious::Routes::Match=HASH(0x55c658302248),,'),(21,1,'243','6346','2017-04-19 12:31:58',''),(22,1,'Поменял','Поменял список на флажки','2017-04-19 12:50:58',''),(23,1,'Проверка 2','Проверка 2','2017-04-19 12:56:37','tomkruzzz,'),(24,1,'rtwe','wert','2017-04-19 12:58:47','tomkruzzz,'),(25,1,'ter','grssgg','2017-04-19 12:59:14','tomkruzzz,'),(26,1,'3767','356775','2017-04-19 13:03:28','ARRAY(0x55c6582c76e8),'),(27,1,'rterte','erterter','2017-04-19 13:07:12','ARRAY(0x55c658304638),'),(28,1,'Ура','Вроде работает','2017-04-19 13:17:29','nikolatesla,tomkruzzz,'),(29,2,'Студентам','Не будет большим злом, если студент впадет в заблуждение; если же ошибаются великие умы, мир дорого оплачивает их ошибки.','2017-04-19 13:20:15','ALL,');
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
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='Пользователи соцсети';
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Павел','Ненашев','nps-11@mail.ru','pavelnen','1234'),(2,'Никола','Тесла','tesla@m.ru','nikolatesla','1234'),(3,'Том','Круз','top@kruz.com','tomkruzzz','1234');
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

-- Dump completed on 2017-05-19 19:39:55
