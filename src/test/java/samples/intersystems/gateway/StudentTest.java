package samples.intersystems.gateway;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;

import java.lang.reflect.Array;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;

import static org.junit.jupiter.api.Assertions.*;

@TestInstance(TestInstance.Lifecycle.PER_CLASS)
public class StudentTest {

    Student student;

    @BeforeAll
    public void setup() {
        student = new Student(29L, "976-01-6712");
        student.mySetName("John", "Smith");
        HashMap<String, String> grades = new HashMap<>();
        grades.put("Biology", "3.1");
        grades.put("French", "3.75");
        grades.put("Spanish", "2.75");
        student.mySetGrades(grades);
    }

    @Test
    public void testGetHighestGrade() throws Exception {
        Float highestGrade = student.myGetHighestGrade();
        assertEquals(highestGrade, 3.75F);
    }

    @Test
    public void testCompletedClasses() {
        HashMap<String, String> grades = student.myGetGrades();
        System.out.println("\n" + grades.getClass());
        System.out.println("\nThe student has completed the following " + grades.size() + " classes:");
        Iterator<String> it = grades.keySet().iterator();
        while (it.hasNext()) {
            String key = it.next();
            String value = grades.get(key);
            System.out.format("\n  %s\t%s", key, value);
        }
    }

    @Test
    public void testNewInstanceForClass() {
        try {
            Class arrayListClass = Class.forName("java.util.ArrayList");
            ArrayList<String> sports = (ArrayList<String>) arrayListClass.getDeclaredConstructor().newInstance();
            assertTrue(sports instanceof ArrayList);
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | InvocationTargetException |
                 NoSuchMethodException e) {
            fail("failed to instantiate ArrayList using newInstance()");
        }
    }

}
