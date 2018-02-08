-- --a
-- SELECT temperature,heartRate
-- FROM Tests t, parients p
-- WHERE t.pid = p.pid and Patients.year < 1950;
-----------------------------------
-- b
CREATE VIEW [FreeBeds] AS
SELECT Wards.number, Wards.numBeds-COUNT(ward))
FROM PatientInWard
GROUP BY ward ;

SELECT * from FreeBeds;