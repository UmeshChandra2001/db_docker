-- ============================================================
-- TFI Heroes Database — MySQL 8.0 compatible (final)
-- ============================================================

CREATE DATABASE IF NOT EXISTS TFI_Heroes
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE TFI_Heroes;

DROP TABLE IF EXISTS Heroes;

-- ------------------------------------------------------------
-- Heroes table
-- NOTE: No generated column, no CURDATE() in CHECK constraints.
-- Both are disallowed by MySQL (non-deterministic functions).
-- ExperienceYears is calculated in the view instead.
-- ------------------------------------------------------------
CREATE TABLE Heroes (
    HeroID           INT AUTO_INCREMENT PRIMARY KEY,
    HeroName         VARCHAR(100) NOT NULL,
    RealName         VARCHAR(100),
    DateOfBirth      DATE,
    DebutYear        INT NOT NULL,
    NumberOfMovies   INT DEFAULT 0,
    SalaryPerMovie   DECIMAL(10,2) NOT NULL COMMENT 'Salary per movie in Crores',
    NetWorth         DECIMAL(10,2) DEFAULT 0 COMMENT 'Net worth in Crores',
    ProductionHouse  VARCHAR(100),
    IsActive         TINYINT(1) DEFAULT 1,
    CreatedDate      DATETIME DEFAULT CURRENT_TIMESTAMP,
    ModifiedDate     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT chk_salary    CHECK (SalaryPerMovie >= 0),
    CONSTRAINT chk_networth  CHECK (NetWorth >= 0),
    CONSTRAINT chk_movies    CHECK (NumberOfMovies >= 0),
    CONSTRAINT chk_debutyear CHECK (DebutYear BETWEEN 1930 AND 2100)
) ENGINE=InnoDB;

-- Indexes
CREATE INDEX idx_hero_name  ON Heroes(HeroName);
CREATE INDEX idx_debut_year ON Heroes(DebutYear);
CREATE INDEX idx_salary     ON Heroes(SalaryPerMovie);
CREATE INDEX idx_active     ON Heroes(IsActive);

-- ------------------------------------------------------------
-- Sample data
-- ------------------------------------------------------------
INSERT INTO Heroes
(HeroName, RealName, DateOfBirth, DebutYear, NumberOfMovies, SalaryPerMovie, NetWorth, ProductionHouse)
VALUES
('Prabhas',          'Uppalapati Venkata Suryanarayana Prabhas Raju', '1979-10-23', 2002, 25, 150.00, 2000.00, 'UV Creations'),
('Mahesh Babu',      'Ghattamaneni Mahesh Babu',                       '1975-08-09', 1979, 30, 100.00, 1800.00, 'G. Mahesh Babu Entertainment'),
('Pawan Kalyan',     'Konidela Kalyan Babu',                           '1971-09-02', 1996, 28,  80.00, 1200.00, 'Pawan Kalyan Creative Works'),
('Allu Arjun',       'Allu Arjun',                                     '1982-04-08', 2003, 22, 120.00, 1500.00, 'Geetha Arts'),
('NTR Jr',           'Nandamuri Taraka Rama Rao Jr',                   '1983-05-20', 1997, 30,  90.00, 1400.00, 'NTR Arts'),
('Ram Charan',       'Konidela Ram Charan Teja',                       '1985-03-27', 2007, 15, 100.00, 1300.00, 'Konidela Production Company'),
('Vijay Deverakonda', 'Vijay Deverakonda',                             '1989-05-09', 2011, 25,  50.00,  500.00, 'Dil Raju Productions'),
('Rana Daggubati',   'Rana Daggubati',                                 '1984-12-14', 2010, 20,  40.00,  400.00, 'Suresh Productions'),
('Nani',             'Ghanta Naveen Babu',                             '1984-02-24', 2008, 30,  35.00,  350.00, 'Wall Poster Cinema'),
('Sai Dharam Tej',   'Sai Dharam Tej',                                 '1986-10-15', 2014, 18,  25.00,  200.00, 'Sri Venkateswara Creations'),
('Nithiin',          'Nithiin Kumar Reddy',                            '1983-03-30', 2002, 28,  30.00,  250.00, 'Sresht Movies'),
('Sharwanand',       'Sharwanand Myneni',                              '1984-03-06', 2004, 30,  20.00,  180.00, 'Sithara Entertainments'),
('Naga Chaitanya',   'Naga Chaitanya Akkineni',                        '1986-11-23', 2009, 22,  30.00,  300.00, 'Annapurna Studios'),
('Akhil Akkineni',   'Akhil Akkineni',                                 '1994-04-08', 2015,  8,  15.00,  100.00, 'Annapurna Studios'),
('Varun Tej',        'Varun Tej Konidela',                             '1990-01-19', 2014, 15,  25.00,  200.00, 'Sri Venkateswara Creations');

-- ------------------------------------------------------------
-- View — ExperienceYears calculated dynamically (CURDATE OK here)
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW vw_ActiveHeroes AS
SELECT
    HeroID,
    HeroName,
    (YEAR(CURDATE()) - DebutYear) AS ExperienceYears,
    NumberOfMovies,
    SalaryPerMovie,
    NetWorth,
    (SalaryPerMovie * NumberOfMovies) AS EstimatedTotalEarnings
FROM Heroes
WHERE IsActive = 1;

-- ------------------------------------------------------------
-- Stored procedure
-- ------------------------------------------------------------
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_GetTopPaidHeroes$$

CREATE PROCEDURE sp_GetTopPaidHeroes(IN p_TopN INT)
BEGIN
    SELECT
        HeroName,
        (YEAR(CURDATE()) - DebutYear) AS ExperienceYears,
        NumberOfMovies,
        SalaryPerMovie,
        NetWorth
    FROM Heroes
    WHERE IsActive = 1
    ORDER BY SalaryPerMovie DESC
    LIMIT p_TopN;
END$$

DROP FUNCTION IF EXISTS fn_CalculateTotalEarnings$$

CREATE FUNCTION fn_CalculateTotalEarnings(p_HeroID INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Total DECIMAL(12,2);

    SELECT (SalaryPerMovie * NumberOfMovies)
    INTO v_Total
    FROM Heroes
    WHERE HeroID = p_HeroID;

    RETURN IFNULL(v_Total, 0);
END$$

DELIMITER ;

-- ------------------------------------------------------------
-- Trigger
-- ------------------------------------------------------------
DELIMITER $$

DROP TRIGGER IF EXISTS trg_Heroes_BeforeUpdate$$

CREATE TRIGGER trg_Heroes_BeforeUpdate
BEFORE UPDATE ON Heroes
FOR EACH ROW
BEGIN
    SET NEW.ModifiedDate = NOW();
END$$

DELIMITER ;
