-- Создаём роль, которую будет использовать PostgREST
create role web_anon nologin;

-- Даём ей права на схему public
grant usage on schema public to web_anon;

-- Создаём таблицу books
create table if not exists books (
  id serial primary key,
  title text not null,
  author text,
  published_at date,
  available boolean default true
);

-- Даём web_anon доступ на чтение и редактирование
grant select, insert, update, delete on books to web_anon;
