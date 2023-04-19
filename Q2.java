import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.Collection;

/*
input:
---------
1 4
1 200 2 4
4 30
3 50 2
2 100
---------
*/

public class Q2 {
    public static void main (String[] args) {
        Scanner in = new Scanner(System.in);
        int o = in.nextInt(), n = in.nextInt();
        Task[] tasks = new Task[n + 1];
        for (int i = 1; i <= n; i++) {
            tasks[i] = new Task(i);
        }
        List<Task> queue = new ArrayList<>();
        in.nextLine();
        while (in.hasNext()) {
            Scanner line = new Scanner(in.nextLine());
            int id = line.nextInt();
            queue.add(tasks[id]);
            tasks[id].setTime(line.nextLong());
            while (line.hasNextInt()) {
                int k = line.nextInt();
                tasks[id].addDependency(tasks[k]);
            }
            line.close();
        }
        ThreadPoolExecutor executor = new ThreadPoolExecutor(
            o,
            o,
            3000,
            TimeUnit.MILLISECONDS,
            new CircularBlockingQueue(queue)
        );
        executor.prestartAllCoreThreads();
        executor.shutdown();
        in.close();
    }
}

class CircularBlockingQueue extends LinkedBlockingQueue<Runnable> {

    public CircularBlockingQueue () {
        super();
    }

    public CircularBlockingQueue (int capacity) {
        super(capacity);
    }
    
    public CircularBlockingQueue (Collection<Task> c) {
        super(c);
    }

    @Override
    public Runnable poll (long timeout, TimeUnit unit) throws InterruptedException {
        Runnable r = null;
        do {
            Task task = (Task) super.poll(timeout, unit);
            if (task == null || task.isReady()) {
                r = task;
                break;
            } else if (!super.offer(task)) {
                throw new InterruptedException();
            }
        } while (true);
        return r;
    }

    @Override
    public Runnable take () throws InterruptedException {
        Runnable r = null;
        do {
            Task task = (Task) super.take();
            if (task.isReady()) {
                r = task;
                break;
            } else {
                super.put(task);
            }
        } while (true);
        return r;
    }
}

class Task implements Runnable {
    private int id;
    private long time;
    public int counter;
    private List<Task> dependants;

    public Task (int id) {
        this.id = id;
        counter = 0;
        dependants = new ArrayList<Task>();
    }
    
    public void run () {
        try {
            Thread.sleep(time);
            System.out.printf("tarefa %d feita\n", id);
            for (Task task : dependants) {
                task.counter--;
            }
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    public void setTime (long time) {
        this.time = time;
    }

    public void addDependency (Task task) {
        task.dependants.add(this);
        counter++;
    }

    public boolean isReady () {
        return counter == 0;
    }
}
