-- Деньги хранятся в целых копейках. Все данные синтетические.
CREATE TABLE customers(customer_id INTEGER PRIMARY KEY, signup_date TEXT NOT NULL);
CREATE TABLE products(product_id INTEGER PRIMARY KEY, name TEXT NOT NULL, category TEXT NOT NULL);
CREATE TABLE orders(order_id INTEGER PRIMARY KEY, customer_id INTEGER NOT NULL REFERENCES customers,
 order_date TEXT NOT NULL, status TEXT NOT NULL CHECK(status IN ('paid','cancelled')));
CREATE TABLE order_items(order_id INTEGER REFERENCES orders, product_id INTEGER REFERENCES products,
 quantity INTEGER NOT NULL CHECK(quantity>0), unit_price_kopecks INTEGER NOT NULL CHECK(unit_price_kopecks>=0),
 PRIMARY KEY(order_id,product_id));
