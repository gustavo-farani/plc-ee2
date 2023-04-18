import java.util.PriorityQueue;
import java.util.Scanner;
import java.util.concurrent.locks.*;

/*
input:
--------
3
3
50
100
250
3
150
200
600
---------
*/

public class Q1 {
    public static void main (String[] args) {
        Scanner in = new Scanner(System.in);
        int k = in.nextInt();
        Airport airport = new Airport(k);
        int n = in.nextInt();
        for (int i = 0; i < n; i++) {
            new Thread(new Flight(airport, new Airplane(in.nextLong(), true))).start();
        }
        n = in.nextInt();
        for (int i = 0; i < n; i++) {
            new Thread(new Flight(airport, new Airplane(in.nextLong(), false))).start();
        }
    }
}

class Airport {
    private int counter;
    PriorityQueue<Airplane> pq;
    private Lock monitor;
    private Condition condition;

    public Airport (int k) {
        this.counter = k;
        this.pq = new PriorityQueue<>();
        this.monitor = new ReentrantLock();
        this.condition = monitor.newCondition();
    }

    public long start (Airplane airplane) throws InterruptedException {
        monitor.lock();
        try {
            if (counter == 0) {
                pq.offer(airplane);
                while (counter == 0 || pq.peek().compareTo(airplane) < 0) {
                    condition.await();
                }
                pq.poll();
            }
            counter--;
            return System.currentTimeMillis();
        } finally {
            monitor.unlock();
        }
    }

    public void finish () throws InterruptedException {
        monitor.lock();
        try {
            counter++;
            condition.signalAll();
        } finally {
            monitor.unlock();
        }
    }
}

class Flight implements Runnable {
    private Airport airport;
    private Airplane airplane;

    public Flight (Airport airport, Airplane airplane) {
        this.airport = airport;
        this.airplane = airplane;
    }

    public void run () {
        try {
            Thread.sleep(airplane.getTime());
            airplane.setTime(airport.start(airplane));
            System.out.println(airplane);
            Thread.sleep(500);
            airport.finish();
        } catch (InterruptedException e) {
            System.out.printf("[FALHA] esperado: %d\n", airplane.getTime());
        }
    }
}

class Airplane implements Comparable<Airplane> {
    public static long zeroTime;

    static {
        zeroTime = System.currentTimeMillis();
    }

    private long expectedTime;
    private long realTime;
    private boolean isArrival;

    public Airplane (long time, boolean isArrival) {
        this.expectedTime = time;
        this.isArrival = isArrival;
    }

    public long getTime () {
        return expectedTime;
    }

    public void setTime (long time) {
        this.realTime = time - zeroTime;
    }

    public String toString () {
        return (this.isArrival ? "[ATERRISAGEM]" : "[DECOLAGEM]")
            + " previsto: "
            + this.expectedTime
            + " ms | real: "
            + this.realTime
            + " ms | atraso: "
            + (this.realTime - this.expectedTime)
            + " ms";
    }

    @Override
    public int compareTo (Airplane other) {
        return Long.compare(this.expectedTime, other.expectedTime);
    }
}
