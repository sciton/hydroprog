#include <stdio.h>
#include "params.h"
#include <GL/gl.h>
#include <GL/glut.h>
#include "calCU.h"
#include <math.h>

#define PI 3.1415926f

void reshape(int w, int h)
{
        glViewport(0, 0, w, h);

        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        gluOrtho2D(0, w, 0, h);

        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
}


void display()
{
    		Step();
				int i = 0;
				float f = 0;
        glClear(GL_COLOR_BUFFER_BIT);
        glPointSize(2);

				glBegin(GL_POLYGON);
					glColor3f(0.4, 0.4, 0.4);

					for(f = 0; f < 2 * PI; f += PI / 70.0f) //<-- Change this floatue
 						glVertex3f(circX+cosf(f)*circR, circY+sinf(f)*circR, 0.0);
				glEnd();


        glBegin(GL_POINTS);
				glColor3f(1.0, 1.0, 1.0);

        for (i = 0; i<NumP; i++)
        {
            glVertex2i(x[i], y[i]);
        }

        glEnd();

        glutSwapBuffers();
}
void timer(int extra)
{
    glutPostRedisplay();
    glutTimerFunc(0, timer, 0);
}

int main (int argc, char * argv[])
{
        glutInit(&argc, argv);
        glutInitDisplayMode(GLUT_DOUBLE|GLUT_RGBA);

        glutInitWindowSize(800, 600);
        glutCreateWindow("OpenGL lesson 1");

        glutReshapeFunc(reshape);
        glutDisplayFunc(display);
        glutTimerFunc(0, timer, 0);
        InitData();
// Step();
        glutMainLoop();

        return 0;
}
