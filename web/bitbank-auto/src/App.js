import React, { useEffect, useMemo, useState, useCallback } from "react";
import moment from "moment";

import { fetchHistory } from "./firebaseAPI";

const App = () => {
  const [histories, setHistories] = useState(null);

  useEffect(() => {
    const fetch = async () => {
      const result = await fetchHistory();
      setHistories(result);
    };

    fetch();
  }, []);

  const calcPl = useCallback((histories) => {
    let pl = 0;
    if (!histories) {
      return pl;
    }

    histories.forEach((h) => {
      if (h.side === "buy") {
        pl = pl - h.price * h.amount;
      } else {
        pl = pl + h.price * h.amount;
      }
    });

    return pl;
  }, [])

  const pl = useMemo(() => {
    return calcPl(histories);
  }, [histories]);

  const prdPl = useMemo(() => {
    return calcPl(histories.filter(h => h.is_production));
  }, [histories]);

  return (
    <>
      <p>本番損益 {prdPl}円</p>
      <p>損益 {pl}円</p>
      <table>
        <thead>
          <tr>
            <th>Datetime</th>
            <th>Side</th>
            <th>Price</th>
            <th>Amount</th>
            <th>Is Production</th>
          </tr>
        </thead>
        {histories && (
          <tbody>
            {histories.map((history, i) => {
              return (
                <tr key={i}>
                  <td>
                    {moment(history.created_at.toDate()).format("M/D hh:mm:ss")}
                  </td>
                  <td>{history.side}</td>
                  <td>{history.price}</td>
                  <td>{history.amount}</td>
                  <td>{history.is_production}</td>
                </tr>
              );
            })}
          </tbody>
        )}
      </table>
    </>
  );
};

export default App;
