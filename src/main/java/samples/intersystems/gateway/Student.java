/**
 * Java Gateway sample java class
 */

package samples.intersystems.gateway;

import java.util.HashMap;
import java.util.Map;

public class Student extends Person {

    public Integer yearsInProgram;

    public float GPA;
    public Float highestGrade;

    public double nextClassCredits;

    public boolean isGraduate;
    public Boolean nextClassOnSchedule;

    public String nextClassLocation;

    public java.sql.Date nextClassDate;
    public java.sql.Time nextClassTime;
    public java.sql.Timestamp chemistryFinal;

    public HashMap<String, String> grades;

    public short classCount;
    public Short credits;

    public Long studentID;

    private int privateInt;

    public Student(Long id, String ssn) {
        super(ssn);
        studentID = id;
        grades = new HashMap<String, String>();
    }

    public Student(String ssn) {
        super(ssn);
        grades = new HashMap<String, String>();
    }

    public Student(Long id) {
        super("111-11-1111");
        studentID = id;
        grades = new HashMap<String, String>();
    }

    public Integer myGetYearsInProgram() {
        return yearsInProgram;
    }

    public void mySetYearsInProgram(Integer value) {
        yearsInProgram = value;
    }

    public Long myGetID() {
        return studentID;
    }

    public void mySetID(Long value) {
        studentID = value;
    }

    public Short myGetCredits() {
        return credits;
    }

    public void mySetCredits(Short value) {
        credits = value;
    }

    public short myGetClasses() {
        return classCount;
    }

    public void mySetClasses(short value) {
        classCount = value;
    }

    public Boolean myGetNextClassOnSchedule() {
        return nextClassOnSchedule;
    }

    public void mySetNextClassOnSchedule(Boolean value) {
        nextClassOnSchedule = value;
    }

    public boolean isGraduateStudent() {
        return isGraduate;
    }

    public void setGraduateStudent(boolean g) {
        isGraduate = g;
    }

    public java.sql.Timestamp myGetChemistryFinal() {
        return chemistryFinal;
    }

    public void mySetChemistryFinal(java.sql.Timestamp value) {
        chemistryFinal = value;
    }

    public java.sql.Date myGetNextClassDate() {
        return nextClassDate;
    }

    public void mySetNextClassDate(java.sql.Date value) {
        nextClassDate = value;
    }

    public java.sql.Time myGetNextClassTime() {
        return nextClassTime;
    }

    public void mySetNextClassTime(java.sql.Time value) {
        nextClassTime = value;
    }

    public void setGrade(String subject, String grade) {
        grades.put(subject, grade);
    }

    public float getGrade(String subject) {
        String grade = (String) grades.get(subject);
        if (grade == null) {
            System.out.println("No grade yet");
        }
        return Float.parseFloat(grade);
    }

    public HashMap<String, String> myGetGrades() {
        return grades;
    }

    public void mySetGrades(HashMap<String, String> g) {
        grades = g;
    }

    public float myGetGPA() {
        return GPA;
    }

    public void mySetGPA(float g) {
        GPA = g;
    }

    public Float myGetHighestGrade() throws Exception {
        Float max = 0.0F;
        if (grades.isEmpty()) {
            throw new Exception("Student has not taken any classes yet");
        }
        try {
            for (Map.Entry<String, String> entry : grades.entrySet()) {
                String key = entry.getKey();
                Float elem = Float.parseFloat(entry.getValue());
                if (elem > max) {
                    max = elem;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return max;
    }

    public void mySetHighestGrade(Float value) {
        highestGrade = value;
    }

    public double mySetNextClassCredits() {
        return nextClassCredits;
    }

    public void myGetNextClassCredits(double value) {
        nextClassCredits = value;
    }

    public boolean setNextClass(java.sql.Date date, java.sql.Time time, String location,
                                double credits, Boolean onSchedule) {
        nextClassOnSchedule = onSchedule;
        nextClassLocation = location;
        nextClassDate = date;
        nextClassTime = time;
        nextClassCredits = credits;
        return onSchedule.booleanValue();
    }

}
