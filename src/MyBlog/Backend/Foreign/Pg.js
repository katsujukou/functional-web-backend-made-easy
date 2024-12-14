import Pg from "pg";

/**
 * 
 * @param {Pg.PoolOptions} opts 
 * @returns 
 */
export function createPool(opts) {
  return function () {
    return new Pg.Pool(opts);
  }
}

/**
 * 
 * @param {Pg.Pool} pool 
 * @returns {Promise<Pg.PoolClient>}
 */
export function connectImpl (pool) {
  return pool.connect();
}

/**
 * 
 * @param {Pg.Pool} pool 
 */
export function endImpl (pool) {
  return pool.end();
}

/**
 * 
 * @param {Pg.PoolClient} client 
 */
export function releaseImpl(client) {
  return client.release();
}

export function sqlNull () {
  return null;
}

/**
 * 
 * @param {Pg.PoolClient} client 
 * @param {string}
 * @param {any[]}
 */
export async function queryImpl (client, sql, values) {
  return await client.query(sql, values);
}