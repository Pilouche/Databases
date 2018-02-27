CREATE OR REPLACE FUNCTION CourseRegistration() RETURNS TRIGGER AS $CourseRegistration$
	DECLARE
	cpt integer;
	maxSeats integer;
	BEGIN
		--The student already applied for the course
		SELECT COUNT(*) INTO cpt FROM Registrations
			WHERE student = NEW.student AND course = NEW.course;
		IF cpt <> 0 THEN
			RAISE EXCEPTION '% has already applied for the course %', NEW.student, NEW.course;
		END IF;

		--The student has already passed the course
		SELECT COUNT(*) INTO cpt FROM PassedCourses
			WHERE student = NEW.student AND course = NEW.course;
		IF cpt <> 0 THEN
			RAISE EXCEPTION '% has already passed the course %', NEW.student, NEW.course;
		END IF;

		--The student isn't allowed to take the course
		SELECT COUNT(*) INTO cpt FROM 
			(SELECT prerequisite FROM Prerequisite WHERE course = NEW.course
				EXCEPT
			SELECT course FROM PassedCourses WHERE student = NEW.student) AS cpt;
		IF cpt <> 0 THEN
			RAISE EXCEPTION '% has not the prerequisites for the course %', NEW.student, NEW.course;
		END IF;

		--Is course the limited ?
		SELECT COUNT(*) INTO cpt FROM LimitedCourse
			WHERE code = NEW.course;
		IF cpt <> 0 THEN
			--Course limited
			SELECT seats INTO maxSeats FROM LimitedCourse
				WHERE code = NEW.course;
			SELECT COUNT(*) INTO cpt FROM Registrations
				WHERE status = 'registered' AND course = NEW.course;
			IF cpt < maxSeats THEN
				--Course not full
				INSERT INTO Registrations VALUES (NEW.student, NEW.course, 'registered');
				RETURN NEW;
			ELSE
				--Course full
				INSERT INTO Registrations VALUES (NEW.student, NEW.course, 'waiting');
				RETURN NEW;
			END IF;
		ELSE
			--Course not limited
			INSERT INTO Registrations VALUES (NEW.student, NEW.course, 'registered');
			RETURN NEW;
		END IF;
	END;
$CourseRegistration$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS CourseRegistration ON Registrations CASCADE;
CREATE TRIGGER CourseRegistration INSTEAD OF INSERT ON Registrations
	FOR EACH ROW WHEN (pg_trigger_depth() = 0) EXECUTE PROCEDURE CourseRegistration();

CREATE OR REPLACE FUNCTION CourseUnregistration() RETURNS TRIGGER AS $CourseUnregistration$
	DECLARE
		cpt INTEGER;
		maxSeats INTEGER;
		newStudent INTEGER;
	BEGIN
		--Update views by removing old student
		DELETE FROM Registrations WHERE student = OLD.student AND course = OLD.course;
		IF OLD.status = 'waiting' THEN
			--Student was waiting so no need for further updates
			RETURN OLD;
		END IF;

		SELECT COUNT(*) INTO cpt FROM LimitedCourse
			WHERE code = OLD.course;
		IF cpt <> 0 THEN
			--Course limited
			SELECT seats INTO maxSeats FROM LimitedCourse
				WHERE code = OLD.course;
			SELECT COUNT(*) INTO cpt FROM Registrations
				WHERE status = 'registered' AND course = OLD.course;
			IF cpt < maxSeats THEN
				--Course not full
				SELECT student INTO newStudent FROM WaitingList
					WHERE course = OLD.course AND position = 1;
				IF newStudent IS NULL THEN
					--No student waiting
					RETURN OLD;
				ELSE
					--At least one student waiting
					INSERT INTO Registrations VALUES (newStudent, OLD.course, 'registered');
					RETURN OLD;
				END IF;
			ELSE
				--Course full
				INSERT INTO Registrations VALUES (newStudent, OLD.course, 'waiting');
			END IF;
		END IF;
		RETURN OLD;
	END;
$CourseUnregistration$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS CourseUnregistration ON Registrations CASCADE;
CREATE TRIGGER CourseUnregistration INSTEAD OF DELETE ON Registrations 
	FOR EACH ROW WHEN (pg_trigger_depth() = 0) EXECUTE PROCEDURE CourseUnregistration();