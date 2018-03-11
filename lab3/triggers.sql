CREATE OR REPLACE FUNCTION CourseRegistration() RETURNS TRIGGER AS $CourseRegistration$
	DECLARE
		cpt integer;
		maxSeats integer;
		maxPos integer;
	BEGIN
		--Avoid recursivity
		IF pg_trigger_depth() <> 1 THEN
			RETURN NEW;
		END IF;
		
		--The student already applied for the course
		SELECT COUNT(*) INTO cpt FROM Registrations
			WHERE student = NEW.student AND course = NEW.course;
		IF cpt <> 0 THEN
			RAISE EXCEPTION 'Student % has already applied for the course %', NEW.student, NEW.course;
		END IF;

		--The student has already passed the course
		SELECT COUNT(*) INTO cpt FROM PassedCourses
			WHERE student = NEW.student AND course = NEW.course;
		IF cpt <> 0 THEN
			RAISE EXCEPTION 'Student % has already passed the course %', NEW.student, NEW.course;
		END IF;

		--The student isn't allowed to take the course
		SELECT COUNT(*) INTO cpt FROM 
			(SELECT prerequisite FROM Prerequisite WHERE course = NEW.course
				EXCEPT
			SELECT course FROM PassedCourses WHERE student = NEW.student) AS cpt;
		IF cpt <> 0 THEN
			RAISE EXCEPTION 'Student % has not the prerequisites for the course %', NEW.student, NEW.course;
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
				INSERT INTO Registered VALUES (NEW.student, NEW.course);
				RAISE NOTICE 'Student % has been successfully registered for the limited course %', NEW.student, NEW.course;
				RETURN NEW;
			ELSE
				--Course full
				SELECT MAX(position) INTO maxPos FROM WaitingList
					WHERE course = NEW.course;
				INSERT INTO WaitingList VALUES (NEW.student, NEW.course, maxPos+1);
				RAISE NOTICE 'Course % is full, student % has put ont the waiting list with position %', NEW.course, NEW.student, maxPos+1;
				RETURN NEW;
			END IF;
		ELSE
			--Course not limited
			INSERT INTO Registered VALUES (NEW.student, NEW.course);
			RAISE NOTICE 'Student % has been successfully registered for the course %', NEW.student, NEW.course;
			RETURN NEW;
		END IF;
		RETURN NEW;
	END;
$CourseRegistration$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS CourseRegistration ON Registrations CASCADE;
CREATE TRIGGER CourseRegistration INSTEAD OF INSERT ON Registrations
	FOR EACH ROW EXECUTE PROCEDURE CourseRegistration();

CREATE OR REPLACE FUNCTION CourseUnregistration() RETURNS TRIGGER AS $CourseUnregistration$
	DECLARE
		cpt INTEGER;
		maxSeats INTEGER;
		oldStudent INTEGER;
		newStudent INTEGER;
		pos integer;
	BEGIN
		--Avoid recursivity
		IF pg_trigger_depth() <> 1 THEN
			RETURN OLD;
		END IF;
		
		--Update tables by removing old student
		IF OLD.status = 'waiting' THEN
			SELECT position INTO pos FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
			DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
			UPDATE WaitingList SET position = position-1 WHERE position > pos AND course = OLD.course;
			RAISE NOTICE 'Student % has been successfully unregistered of the waiting list for the course %', OLD.student, OLD.course;
			--Student was waiting so no need for further updates
			RETURN OLD;
		ELSE
			DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
			RAISE NOTICE 'Student % has been successfully unregistered of the course %', OLD.student, OLD.course;
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
					INSERT INTO Registered VALUES (newStudent, OLD.course);
					DELETE FROM WaitingList WHERE student = newStudent AND course = OLD.course;
					UPDATE WaitingList SET position = position-1 WHERE course = OLD.course;
					RETURN OLD;
				END IF;
			ELSE
				--Course full
				RETURN OLD;
			END IF;
		END IF;
		RETURN OLD;
	END;
$CourseUnregistration$ LANGUAGE PLPGSQL;

DROP TRIGGER IF EXISTS CourseUnregistration ON Registrations CASCADE;
CREATE TRIGGER CourseUnregistration INSTEAD OF DELETE ON Registrations 
	FOR EACH ROW EXECUTE PROCEDURE CourseUnregistration();