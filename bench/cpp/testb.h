#ifndef	TESTB_H
#define	TESTB_H

template <class VA>	class TESTB {
public:
	VA	*m_core;
	unsigned long	m_tickcount;

	TESTB(void) { m_core = new VA; }
	~TESTB(void) { delete m_core; m_core = NULL; }

	virtual	void	eval(void) {
		m_core->eval();
	}

	virtual	void	tick(void) {
		m_core->i_clk = 0;
		eval();
		m_core->i_clk = 1;
		eval();

		m_tickcount++;
	}
};

#endif
